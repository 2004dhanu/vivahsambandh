import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../models/education_model.dart';
import '../../models/community_model.dart';
import '../../models/gotra_model.dart';
import '../../models/profession_model.dart';
import '../../models/user_model.dart';
import '../../models/member_item_model.dart';
import '../../models/shortlist_model.dart';
import '../../models/feedback_model.dart';
import '../../models/block_profile_model.dart';
import '../../models/notification_model.dart';
import '../../models/payment_history_model.dart';
import '../services/firebase_notification_service.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  /// GET: Education list
  Future<List<EducationModel>> getEducationList() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getEducation);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] as List? ?? [];
        return list.map((item) => EducationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error fetching education list: $e");
      return [];
    }
  }

  /// GET: Community list
  Future<List<CommunityModel>> getCommunityList() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getCommunity);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] as List? ?? [];
        return list.map((item) => CommunityModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error fetching community list: $e");
      return [];
    }
  }

  /// GET: Gotra list by community ID
  Future<List<GotraModel>> getGotraList(int communityId) async {
    try {
      final endpoint = '${ApiEndpoints.getGotra}/$communityId';
      final response = await _client.dio.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] as List? ?? [];
        return list.map((item) => GotraModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error fetching gotra list for community $communityId: $e");
      return [];
    }
  }

  /// GET: Profession list
  Future<List<ProfessionModel>> getProfessionList() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getProfession);
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['data'] as List? ?? [];
        return list.map((item) => ProfessionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error fetching profession list: $e");
      return [];
    }
  }

  /// POST: Check mobile registered status
  Future<Map<String, dynamic>> checkMobile(String mobile) async {
    try {
      final formData = FormData.fromMap({'mobile': mobile});
      final response = await _client.dio.post(
        ApiEndpoints.appCheckMobile,
        data: formData,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'code': response.statusCode, 'message': response.statusMessage};
    } catch (e) {
      debugPrint("❌ Error checking mobile: $e");
      return {'code': 500, 'message': 'Network error checking mobile'};
    }
  }

  /// POST: App Login (Supports User, Admin, and Super Admin)
  Future<Map<String, dynamic>> appLogin({
    required String mobile,
    required String password,
    String? deviceId,
  }) async {
    try {
      // In the device_id place pass the real FCM token and send it to the backend
      String fcmToken = (deviceId != null && deviceId.trim().length > 30)
          ? deviceId.trim()
          : await FirebaseNotificationService.instance.getFcmToken();

      if (fcmToken.isEmpty) {
        try {
          fcmToken = (await FirebaseMessaging.instance.getToken()) ?? '';
        } catch (_) {}
      }

      debugPrint("🚀 [appLogin] Sending real FCM Token in device_id: $fcmToken");

      final formData = FormData.fromMap({
        'mobile': mobile.trim(),
        'profile_id': mobile.trim(),
        'password': password.trim(),
        'device_id': fcmToken,
        'profile_device_id': fcmToken,
        'device_token': fcmToken,
        'fcm_token': fcmToken,
      });

      final response = await _client.dio.post(
        ApiEndpoints.appLogin,
        data: formData,
      );

      debugPrint("Login Response: [${response.statusCode}] ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          final token = innerData['token']?.toString();
          if (token != null && token.isNotEmpty) {
            await _client.setToken(token);
          }
          final userJson = Map<String, dynamic>.from(innerData['user'] as Map<String, dynamic>? ?? {});
          userJson['payment_details'] = data['payment_details'] ?? innerData['payment_details'] ?? userJson['payment_details'];
          final user = UserModel.fromJson(userJson);
          // Subscribe user or admin to appropriate FCM topics
          await FirebaseNotificationService.instance.configureUserTopics(user);

          return {
            'success': true,
            'token': token,
            'user': user,
            'message': data['message'] ?? 'Login successful',
          };
        }
      }

      final errorMsg = response.data is Map
          ? (response.data['message']?.toString() ?? 'Invalid credentials')
          : 'Invalid credentials. Please try again.';

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      debugPrint("❌ Error logging in: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// GET: Pending Members (for Admin & Super Admin)
  Future<Map<String, dynamic>> getPendingMembers() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getPendingMember);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final members = list
            .map((item) => MemberItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'members': members,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load pending members',
      };
    } catch (e) {
      debugPrint("❌ Error fetching pending members: $e");
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// GET: All / Approved Members (for Admin, Super Admin, and Candidate with filters)
  Future<Map<String, dynamic>> getAllMembers({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.member,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final members = list
            .map((item) => MemberItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'members': members,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load members',
      };
    } catch (e) {
      debugPrint("❌ Error fetching members: $e");
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// Check if a mobile number is already registered and approved/pending
  Future<MemberItemModel?> checkExistingMemberByMobile(String mobile) async {
    try {
      final cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');
      final tenDigit = cleanMobile.length >= 10 ? cleanMobile.substring(cleanMobile.length - 10) : cleanMobile;

      // Check mobile status using checkMobile first if no active token
      // 1. Primary check: Use checkMobile endpoint (works for any user without token)
      final mobileCheck = await checkMobile(tenDigit);
      debugPrint("checkMobile result for $tenDigit: code=${mobileCheck['code']}, msg=${mobileCheck['message']}");
      if (mobileCheck['code'] == 200) {
        // Registered user! The backend returns the OTP code in 'data'
        final otpCode = mobileCheck['data']?.toString() ?? '';
        if (otpCode.isNotEmpty) {
          final loginRes = await appLogin(mobile: tenDigit, password: otpCode);
          if (loginRes['success'] == true && loginRes['user'] is UserModel) {
            final u = loginRes['user'] as UserModel;
            return MemberItemModel(
              id: u.id,
              name: u.name,
              mobile: u.mobile,
              gender: u.gender ?? '',
              userType: u.userType,
              status: u.status,
              faceImage: u.faceImage,
              registerDate: u.registerDate,
              userCurrentCity: u.userCurrentCity,
              paymentDetails: u.paymentDetails,
            );
          }
        }
      } else if (mobileCheck['code'] == 404) {
        debugPrint("Mobile $tenDigit is not registered on CRM (404)");
        return null;
      } else if (mobileCheck['data'] is Map<String, dynamic>) {
        try {
          return MemberItemModel.fromJson(mobileCheck['data'] as Map<String, dynamic>);
        } catch (_) {}
      }

      // 1. Check in all members
      final allRes = await getAllMembers();
      if (allRes['success'] == true && allRes['members'] is List<MemberItemModel>) {
        final list = allRes['members'] as List<MemberItemModel>;
        for (var m in list) {
          final mMobile = m.mobile?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          final altMobile = m.alternateMobileNo?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          if ((mMobile.isNotEmpty && (mMobile.endsWith(tenDigit) || tenDigit.endsWith(mMobile))) ||
              (altMobile.isNotEmpty && (altMobile.endsWith(tenDigit) || tenDigit.endsWith(altMobile)))) {
            debugPrint("✅ Found existing member in /member: ${m.name} (id: ${m.id})");
            return m;
          }
        }
      }

      // 2. Check in pending members
      final pendingRes = await getPendingMembers();
      if (pendingRes['success'] == true && pendingRes['members'] is List<MemberItemModel>) {
        final list = pendingRes['members'] as List<MemberItemModel>;
        for (var m in list) {
          final mMobile = m.mobile?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          final altMobile = m.alternateMobileNo?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          if ((mMobile.isNotEmpty && (mMobile.endsWith(tenDigit) || tenDigit.endsWith(mMobile))) ||
              (altMobile.isNotEmpty && (altMobile.endsWith(tenDigit) || tenDigit.endsWith(altMobile)))) {
            debugPrint("✅ Found existing member in /getPendingMember: ${m.name} (id: ${m.id})");
            return m;
          }
        }
      }

      // 3. Check in admin members (for user_type 2)
      final adminRes = await getAdminMembers();
      if (adminRes['success'] == true && adminRes['members'] is List<MemberItemModel>) {
        final list = adminRes['members'] as List<MemberItemModel>;
        for (var m in list) {
          final mMobile = m.mobile?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          final altMobile = m.alternateMobileNo?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          if ((mMobile.isNotEmpty && (mMobile.endsWith(tenDigit) || tenDigit.endsWith(mMobile))) ||
              (altMobile.isNotEmpty && (altMobile.endsWith(tenDigit) || tenDigit.endsWith(altMobile)))) {
            debugPrint("✅ Found existing admin in /getAdminMember: ${m.name} (id: ${m.id}) user_type: ${m.userType}");
            return m;
          }
        }
      }

      // 4. Check in pending admin members
      final pendingAdminRes = await getPendingAdminMembers();
      if (pendingAdminRes['success'] == true && pendingAdminRes['members'] is List<MemberItemModel>) {
        final list = pendingAdminRes['members'] as List<MemberItemModel>;
        for (var m in list) {
          final mMobile = m.mobile?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          final altMobile = m.alternateMobileNo?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          if ((mMobile.isNotEmpty && (mMobile.endsWith(tenDigit) || tenDigit.endsWith(mMobile))) ||
              (altMobile.isNotEmpty && (altMobile.endsWith(tenDigit) || tenDigit.endsWith(altMobile)))) {
            debugPrint("✅ Found existing pending admin in /getPendingAdminMember: ${m.name} (id: ${m.id}) user_type: ${m.userType}");
            return m;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint("❌ Error checking existing member: $e");
      return null;
    }
  }

  /// GET: Admin Members (for Super Admin)
  Future<Map<String, dynamic>> getAdminMembers() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getAdminMember);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final members = list
            .map((item) => MemberItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'members': members,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load admin members',
      };
    } catch (e) {
      debugPrint("❌ Error fetching admin members: $e");
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// GET: Pending Admin Members (for Super Admin)
  Future<Map<String, dynamic>> getPendingAdminMembers() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getPendingAdminMember);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final members = list
            .map((item) => MemberItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'members': members,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load pending admin members',
      };
    } catch (e) {
      debugPrint("❌ Error fetching pending admin members: $e");
      return {
        'success': false,
        'members': <MemberItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// PATCH: Update Member Status (Pending, Approved, Hold, Married, Cancel)
  /// Uses POST with `_method: PATCH` which is required for Laravel multipart parsing
  Future<Map<String, dynamic>> updateMemberStatus({
    required int memberId,
    required String status,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PATCH',
        'status': status,
      });

      final endpoint = ApiEndpoints.updateMemberStatus(memberId);
      final response = await _client.dio.post(
        endpoint,
        data: formData,
      );

      debugPrint("Update Status Response: [${response.statusCode}] ${response.data}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Profile Status Updated Successfully.',
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Failed to update status',
        };
      }
    } catch (e) {
      debugPrint("❌ Error updating member status: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// PUT: Update Member City (multiple_city separated by comma)
  /// Uses POST with `_method: PUT` for Laravel form-data compatibility
  Future<Map<String, dynamic>> updateMemberCity({
    required int memberId,
    required String multipleCity,
  }) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'multiple_city': multipleCity.trim(),
      });

      final endpoint = ApiEndpoints.updateMemberCity(memberId);
      final response = await _client.dio.post(
        endpoint,
        data: formData,
      );

      debugPrint("Update City Response: [${response.statusCode}] ${response.data}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Profile City Updated Successfully.',
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Failed to update city',
        };
      }
    } catch (e) {
      debugPrint("❌ Error updating member city: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// PUT: Update Admin Member
  /// Required fields: name, gender, email, user_address, user_current_city, mobile, optional face_image
  Future<Map<String, dynamic>> updateAdminMember({
    required int adminId,
    required String name,
    required String gender,
    required String email,
    required String userAddress,
    required String userCurrentCity,
    required String mobile,
    File? faceImage,
  }) async {
    try {
      final Map<String, dynamic> map = {
        '_method': 'PUT',
        'name': name.trim(),
        'gender': gender.trim(),
        'email': email.trim(),
        'user_address': userAddress.trim(),
        'user_current_city': userCurrentCity.trim(),
        'mobile': mobile.trim(),
      };

      if (faceImage != null) {
        final fileName = faceImage.path.split('/').last.split('\\').last;
        map['face_image'] = await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(map);
      final endpoint = ApiEndpoints.updateAdminMember(adminId);
      final response = await _client.dio.post(
        endpoint,
        data: formData,
      );

      debugPrint("Update Admin Response: [${response.statusCode}] ${response.data}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Admin Member Updated Successfully.',
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'Failed to update admin member',
        };
      }
    } catch (e) {
      debugPrint("❌ Error updating admin member: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// GET: Member by ID
  Future<Map<String, dynamic>> getMemberById(int id) async {
    try {
      final endpoint = ApiEndpoints.memberById(id);
      final response = await _client.dio.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final memberJson = data['data'] as Map<String, dynamic>?;
        if (memberJson != null) {
          final memberMap = Map<String, dynamic>.from(memberJson);
          if (memberMap['payment_details'] == null && data['payment_details'] != null) {
            memberMap['payment_details'] = data['payment_details'];
          }
          final member = MemberItemModel.fromJson(memberMap);

          String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
          if (data['image_url'] is List) {
            for (var img in (data['image_url'] as List)) {
              if (img is Map && img['image_for'] == 'User') {
                userImageBase = img['image_url']?.toString() ?? userImageBase;
                break;
              }
            }
          }

          return {
            'success': true,
            'member': member,
            'user_image_base': userImageBase,
          };
        }
      }
      return {
        'success': false,
        'message': response.data?['message'] ?? 'Failed to load member profile',
      };
    } catch (e) {
      debugPrint("❌ Error fetching member by id $id: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// GET: Wishlist profiles list
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/wishlist
  /// Headers: Authorization: Bearer `token`
  Future<Map<String, dynamic>> getWishlist() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.wishlist);
      debugPrint("Wishlist GET response: [${response.statusCode}] ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data;
        List list = [];
        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';

        if (rawData is Map<String, dynamic>) {
          if (rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData['wishlist'] is List) {
            list = rawData['wishlist'] as List;
          }
          if (rawData['image_url'] is List) {
            for (var img in (rawData['image_url'] as List)) {
              if (img is Map && img['image_for'] == 'User') {
                userImageBase = img['image_url']?.toString() ?? userImageBase;
                break;
              }
            }
          }
        } else if (rawData is List) {
          list = rawData;
        }

        final items = list
            .whereType<Map<String, dynamic>>()
            .map((item) => ShortlistItemModel.fromJson(item))
            .toList();

        return {
          'success': true,
          'shortlists': items,
          'wishlists': items,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'shortlists': <ShortlistItemModel>[],
        'wishlists': <ShortlistItemModel>[],
        'message': response.data is Map ? response.data['message'] : 'Failed to load wishlist',
      };
    } catch (e) {
      debugPrint("❌ Error fetching wishlist: $e");
      return {
        'success': false,
        'shortlists': <ShortlistItemModel>[],
        'wishlists': <ShortlistItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// Alias for backward compatibility
  Future<Map<String, dynamic>> getShortlist() => getWishlist();

  /// POST: Add profile to wishlist (to_id: candidate member id)
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/wishlist
  /// Body: formdata with to_id
  Future<Map<String, dynamic>> addToWishlist(int toId) async {
    try {
      final formData = FormData.fromMap({'to_id': toId.toString()});
      final response = await _client.dio.post(
        ApiEndpoints.wishlist,
        data: formData,
      );
      debugPrint("Wishlist POST response: [${response.statusCode}] ${response.data}");
      final code = response.data is Map ? (response.data['code'] ?? response.statusCode) : response.statusCode;
      final msg = response.data is Map
          ? (response.data['message']?.toString() ?? 'Profile added to wishlist.')
          : 'Profile added to wishlist.';
      return {
        'success': code == 200 || code == 201 || (response.statusCode != null && response.statusCode! < 300),
        'code': code,
        'message': msg,
        'data': response.data,
      };
    } catch (e) {
      debugPrint("❌ Error adding to wishlist $toId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// Alias for backward compatibility
  Future<Map<String, dynamic>> shortlistProfile(int toId) => addToWishlist(toId);

  /// DELETE: Remove profile from wishlist by wishlist row ID
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/wishlist/{id}
  Future<Map<String, dynamic>> removeFromWishlist(int wishlistId) async {
    try {
      final endpoint = ApiEndpoints.wishlistById(wishlistId);
      final response = await _client.dio.delete(endpoint);
      debugPrint("Delete Wishlist response: [${response.statusCode}] ${response.data}");
      final code = response.data is Map ? (response.data['code'] ?? response.statusCode) : response.statusCode;
      final msg = response.data is Map
          ? (response.data['message']?.toString() ?? 'Profile removed from wishlist.')
          : 'Profile removed from wishlist.';
      return {
        'success': code == 200 || code == 201 || (response.statusCode != null && response.statusCode! < 300),
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error removing wishlist $wishlistId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// Alias for backward compatibility
  Future<Map<String, dynamic>> removeShortlist(int wishlistId) => removeFromWishlist(wishlistId);

  /// GET: Notification by ID (User / Admin / Super Admin)
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/notification/{id}
  /// Headers: Authorization: Bearer `token`
  Future<Map<String, dynamic>> getNotificationById(int id) async {
    try {
      final endpoint = ApiEndpoints.notificationById(id);
      final response = await _client.dio.get(endpoint);
      debugPrint("Notification GET [$id] response: [${response.statusCode}] ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        List list = [];

        if (raw is Map<String, dynamic>) {
          if (raw['data'] is List) {
            list = raw['data'] as List;
          } else if (raw['notifications'] is List) {
            list = raw['notifications'] as List;
          } else if (raw['data'] is Map<String, dynamic>) {
            list = [raw['data']];
          }
        } else if (raw is List) {
          list = raw;
        }

        final items = list
            .whereType<Map<String, dynamic>>()
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        return {
          'success': true,
          'notifications': items,
        };
      }

      return {
        'success': false,
        'notifications': <NotificationModel>[],
        'message': response.data is Map ? response.data['message'] : 'No notifications found.',
      };
    } catch (e) {
      debugPrint("❌ Error fetching notification $id: $e");
      return {
        'success': false,
        'notifications': <NotificationModel>[],
        'message': e.toString(),
      };
    }
  }

  /// DELETE: Notification by ID
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/notification/{id}
  /// Headers: Authorization: Bearer `token`
  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final endpoint = ApiEndpoints.notificationById(id);
      final response = await _client.dio.delete(endpoint);
      debugPrint("Delete Notification [$id] response: [${response.statusCode}] ${response.data}");

      final code = response.data is Map ? (response.data['code'] ?? response.statusCode) : response.statusCode;
      final msg = response.data is Map
          ? (response.data['message']?.toString() ?? 'Notification deleted successfully.')
          : 'Notification deleted successfully.';

      return {
        'success': code == 200 || code == 201 || (response.statusCode != null && response.statusCode! < 300),
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error deleting notification $id: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// GET: Feedback list
  Future<Map<String, dynamic>> getFeedbackList() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.feedback);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final items = list
            .map((item) => FeedbackItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'feedbacks': items,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'feedbacks': <FeedbackItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load feedbacks',
      };
    } catch (e) {
      debugPrint("❌ Error fetching feedbacks: $e");
      return {
        'success': false,
        'feedbacks': <FeedbackItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// POST: Submit feedback for a candidate
  Future<Map<String, dynamic>> submitFeedback({
    required int toProfileId,
    required String description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'to_profile_id': toProfileId.toString(),
        'feedback_description': description.trim(),
      });
      final response = await _client.dio.post(
        ApiEndpoints.feedback,
        data: formData,
      );
      debugPrint("Feedback POST response: [${response.statusCode}] ${response.data}");
      final code = response.data?['code'] ?? response.statusCode;
      final msg = response.data?['message']?.toString() ?? 'Feedback is Successfully Created.';
      return {
        'success': code == 200 || code == 201,
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error creating feedback for profile $toProfileId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// DELETE: Remove feedback by feedback row ID
  Future<Map<String, dynamic>> deleteFeedback(int feedbackId) async {
    try {
      final endpoint = ApiEndpoints.feedbackById(feedbackId);
      final response = await _client.dio.delete(endpoint);
      debugPrint("Delete Feedback response: [${response.statusCode}] ${response.data}");
      final code = response.data?['code'] ?? response.statusCode;
      final msg = response.data?['message']?.toString() ?? 'Feedback Successfully Removed.';
      return {
        'success': code == 200 || code == 201,
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error deleting feedback $feedbackId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// GET: Blocked profiles list
  Future<Map<String, dynamic>> getBlockedProfiles() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.blockProfile);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final items = list
            .map((item) => BlockProfileItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'blockedProfiles': items,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'blockedProfiles': <BlockProfileItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load blocked profiles',
      };
    } catch (e) {
      debugPrint("❌ Error fetching blocked profiles: $e");
      return {
        'success': false,
        'blockedProfiles': <BlockProfileItemModel>[],
        'message': e.toString(),
      };
    }
  }

  /// POST: Block a profile
  Future<Map<String, dynamic>> blockProfile({
    required int toId,
    required String description,
    int? reasonValue,
    String? reasonTitle,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'to_id': toId.toString(),
        'blockprofile_description': description.trim(),
      };
      if (reasonValue != null) {
        data['reason'] = reasonValue.toString();
        data['value'] = reasonValue.toString();
        data['blockprofile_reason'] = reasonValue.toString();
        data['reason_value'] = reasonValue.toString();
      }
      if (reasonTitle != null && reasonTitle.isNotEmpty) {
        data['title'] = reasonTitle;
        data['reason_title'] = reasonTitle;
      }
      final formData = FormData.fromMap(data);
      final response = await _client.dio.post(
        ApiEndpoints.blockProfile,
        data: formData,
      );
      debugPrint("Block POST response: [${response.statusCode}] ${response.data}");
      final code = response.data?['code'] ?? response.statusCode;
      final msg = response.data?['message']?.toString() ?? 'Profile is Successfully Blocked.';
      return {
        'success': code == 200 || code == 201,
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error blocking profile $toId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// DELETE: Unblock profile by block row ID
  Future<Map<String, dynamic>> unblockProfile(int blockId) async {
    try {
      final endpoint = ApiEndpoints.blockProfileById(blockId);
      final response = await _client.dio.delete(endpoint);
      debugPrint("Delete Block response: [${response.statusCode}] ${response.data}");
      final code = response.data?['code'] ?? response.statusCode;
      final msg = response.data?['message']?.toString() ?? 'Profile Successfully Removed.';
      return {
        'success': code == 200 || code == 201,
        'message': msg,
      };
    } catch (e) {
      debugPrint("❌ Error unblocking profile $blockId: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }



  /// POST: Logout
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.appLogout);
    } catch (_) {}
    await _client.clearToken();
  }

  /// POST: Delete Profile / Account
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/app-delete-profile
  Future<Map<String, dynamic>> deleteProfile({int? userId}) async {
    try {
      final Map<String, dynamic> data = {};
      if (userId != null && userId > 0) {
        data['user_id'] = userId;
        data['id'] = userId;
      }
      final response = await _client.dio.post(
        ApiEndpoints.appDeleteProfile,
        data: data.isNotEmpty ? FormData.fromMap(data) : null,
      );
      debugPrint("Delete Profile response: [${response.statusCode}] ${response.data}");
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data is Map ? (response.data['message'] ?? 'Account deleted successfully') : 'Account deleted successfully',
        };
      }
      return {
        'success': false,
        'message': response.data is Map ? (response.data['message'] ?? 'Failed to delete account') : 'Failed to delete account',
      };
    } catch (e) {
      debugPrint("❌ Error deleting profile: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// GET: Payment History
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/getPaymentHistory
  Future<Map<String, dynamic>> getPaymentHistory({int? userId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (userId != null && userId > 0) {
        params['user_id'] = userId;
      }
      final response = await _client.dio.get(
        ApiEndpoints.getPaymentHistory,
        queryParameters: params.isNotEmpty ? params : null,
      );
      debugPrint("Payment History response: [${response.statusCode}] ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List list = data['data'] as List? ?? [];
        final items = list
            .map((item) => PaymentHistoryItemModel.fromJson(item as Map<String, dynamic>))
            .toList();

        String userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
        if (data['image_url'] is List) {
          for (var img in (data['image_url'] as List)) {
            if (img is Map && img['image_for'] == 'User') {
              userImageBase = img['image_url']?.toString() ?? userImageBase;
              break;
            }
          }
        }

        return {
          'success': true,
          'data': items,
          'user_image_base': userImageBase,
        };
      }
      return {
        'success': false,
        'data': <PaymentHistoryItemModel>[],
        'message': response.data?['message'] ?? 'Failed to load payment history',
      };
    } catch (e) {
      debugPrint("❌ Error fetching payment history: $e");
      return {
        'success': false,
        'data': <PaymentHistoryItemModel>[],
        'message': e.toString(),
      };
    }
  }



  /// POST: Create user registration with Multipart FormData
  Future<Map<String, dynamic>> registerUser({
    required Map<String, dynamic> fields,
    File? fullImage,
    File? faceImage,
  }) async {
    try {
      final Map<String, dynamic> map = Map<String, dynamic>.from(fields);

      if (!map.containsKey('device_id') || map['device_id'] == null || map['device_id'].toString().isEmpty) {
        map['device_id'] = await FirebaseNotificationService.instance.getFcmToken();
      }

      if (fullImage != null && await fullImage.exists()) {
        final fileName = fullImage.path.split(Platform.pathSeparator).last;
        map['full_image'] = await MultipartFile.fromFile(
          fullImage.path,
          filename: fileName,
        );
      }

      if (faceImage != null && await faceImage.exists()) {
        final fileName = faceImage.path.split(Platform.pathSeparator).last;
        map['face_image'] = await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _client.dio.post(
        ApiEndpoints.createUserRegister,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint("Registration Response: ${response.statusCode} -> ${response.data}");

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'status': response.statusCode == 200,
          'message': response.statusMessage ?? 'Request processed',
          'data': response.data,
        };
      }
    } catch (e) {
      debugPrint("❌ Error registering user: $e");
      if (e is DioException) {
        final resp = e.response?.data;
        if (resp is Map<String, dynamic>) {
          return resp;
        }
        return {
          'status': false,
          'message': e.message ?? 'Network connection error',
        };
      }
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  /// PUT: Remove Device ID on Logout
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/removeDeviceId/{userId}
  Future<Map<String, dynamic>> removeDeviceId(int userId) async {
    try {
      final endpoint = ApiEndpoints.removeDeviceId(userId);
      final response = await _client.dio.put(endpoint, data: {});
      debugPrint("removeDeviceId response: [${response.statusCode}] ${response.data}");
      final code = response.data is Map ? (response.data['code'] ?? response.statusCode) : response.statusCode;
      return {
        'success': code == 200 || code == 201 || (response.statusCode != null && response.statusCode! < 300),
        'message': response.data is Map ? response.data['message']?.toString() : 'Device ID removed successfully',
      };
    } catch (e) {
      debugPrint("❌ Error removing device ID: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET: Company Details & Settings
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/getCompany
  Future<Map<String, dynamic>> getCompany() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.getCompany);
      debugPrint("getCompany response: [${response.statusCode}] ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic> ? response.data : {};
        return {
          'success': true,
          'company': data['data'],
          'image_url': data['image_url'],
        };
      }
      return {'success': false, 'message': 'Failed to load company details'};
    } catch (e) {
      debugPrint("❌ Error fetching company details: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST: Create User Payment Record
  /// Endpoint: https://vivahsambandh.com/crmapi/public/api/create-user-payment
  Future<Map<String, dynamic>> createUserPayment({
    required int userId,
    required String paymentMethod,
    required String paymentDetails,
    String paymentStatus = 'Pending',
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'payment_method': paymentMethod,
        'payment_details': paymentDetails,
        'payment_status': paymentStatus,
      });
      final response = await _client.dio.post(
        ApiEndpoints.createUserPayment,
        data: formData,
      );
      debugPrint("createUserPayment response: [${response.statusCode}] ${response.data}");
      final code = response.data is Map ? (response.data['code'] ?? response.statusCode) : response.statusCode;
      return {
        'success': code == 200 || code == 201 || (response.statusCode != null && response.statusCode! < 300),
        'message': response.data is Map ? response.data['message']?.toString() : 'Payment submitted successfully',
        'data': response.data,
      };
    } catch (e) {
      debugPrint("❌ Error creating user payment: $e");
      return {'success': false, 'message': e.toString()};
    }
  }
}
