import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/member_item_model.dart';
import '../models/user_model.dart';

class AdminController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final RxList<MemberItemModel> pendingMembers = <MemberItemModel>[].obs;
  final RxList<MemberItemModel> allMembers = <MemberItemModel>[].obs;
  final RxList<MemberItemModel> pendingAdminMembers = <MemberItemModel>[].obs;
  final RxList<MemberItemModel> adminMembers = <MemberItemModel>[].obs;

  final RxBool isLoadingPending = false.obs;
  final RxBool isLoadingAll = false.obs;
  final RxBool isLoadingPendingAdmin = false.obs;
  final RxBool isLoadingAdmin = false.obs;
  final RxMap<int, bool> updatingMemberStatusMap = <int, bool>{}.obs;

  final RxString userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/'.obs;

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  final RxString selectedGenderFilter = 'All'.obs; // 'All', 'Male', 'Female'
  final RxString selectedStatusFilter = 'All'.obs; // 'All', 'Approved', 'Pending', 'Hold', 'Married', 'Cancel'

  final List<String> statusOptions = [
    'Pending',
    'Approved',
    'Hold',
    'Married',
    'Cancel',
  ];

  AdminController({UserModel? user}) {
    if (user != null) {
      currentUser.value = user;
    } else {
      SessionManager.instance.getUser().then((u) {
        if (u != null) {
          currentUser.value = u;
        }
      });
    }
  }

  bool get isSuperAdmin => currentUser.value?.isSuperAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> refreshAllData() async {
    final futures = <Future>[
      fetchPendingMembers(),
      fetchAllMembers(),
    ];
    if (isSuperAdmin) {
      futures.add(fetchPendingAdminMembers());
      futures.add(fetchAdminMembers());
    }
    await Future.wait(futures);
  }

  /// Fetch Pending Members
  Future<void> fetchPendingMembers() async {
    isLoadingPending.value = true;
    try {
      final res = await _apiService.getPendingMembers();
      if (res['success'] == true) {
        pendingMembers.assignAll(res['members'] as List<MemberItemModel>);
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'];
        }
      } else {
        Get.snackbar(
          'Error',
          res['message']?.toString() ?? 'Failed to load pending members',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error fetching pending: $e");
    } finally {
      isLoadingPending.value = false;
    }
  }

  /// Fetch All Members
  Future<void> fetchAllMembers() async {
    isLoadingAll.value = true;
    try {
      final res = await _apiService.getAllMembers();
      if (res['success'] == true) {
        allMembers.assignAll(res['members'] as List<MemberItemModel>);
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'];
        }
      } else {
        Get.snackbar(
          'Error',
          res['message']?.toString() ?? 'Failed to load members',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error fetching all: $e");
    } finally {
      isLoadingAll.value = false;
    }
  }

  /// Fetch Pending Admin Members (Super Admin only)
  Future<void> fetchPendingAdminMembers() async {
    isLoadingPendingAdmin.value = true;
    try {
      final res = await _apiService.getPendingAdminMembers();
      if (res['success'] == true) {
        pendingAdminMembers.assignAll(res['members'] as List<MemberItemModel>);
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'];
        }
      } else {
        Get.snackbar(
          'Error',
          res['message']?.toString() ?? 'Failed to load pending admin members',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error fetching pending admin members: $e");
    } finally {
      isLoadingPendingAdmin.value = false;
    }
  }

  /// Fetch Admin Members (Super Admin only)
  Future<void> fetchAdminMembers() async {
    isLoadingAdmin.value = true;
    try {
      final res = await _apiService.getAdminMembers();
      if (res['success'] == true) {
        adminMembers.assignAll(res['members'] as List<MemberItemModel>);
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'];
        }
      } else {
        Get.snackbar(
          'Error',
          res['message']?.toString() ?? 'Failed to load admin members',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error fetching admin members: $e");
    } finally {
      isLoadingAdmin.value = false;
    }
  }

  /// Update Member Status using the status dropdown
  Future<void> updateStatus(MemberItemModel member, String newStatus) async {
    if (member.status.toLowerCase() == newStatus.toLowerCase()) return;

    updatingMemberStatusMap[member.id] = true;

    try {
      final res = await _apiService.updateMemberStatus(
        memberId: member.id,
        status: newStatus,
      );

      updatingMemberStatusMap[member.id] = false;

      if (res['success'] == true) {
        member.status = newStatus;
        pendingMembers.refresh();
        allMembers.refresh();
        pendingAdminMembers.refresh();
        adminMembers.refresh();

        Get.snackbar(
          'Status Updated',
          '${member.name}\'s profile status has been updated to $newStatus.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Refresh lists in background to sync with server
        fetchPendingMembers();
        fetchAllMembers();
        if (isSuperAdmin) {
          fetchPendingAdminMembers();
          fetchAdminMembers();
        }
      } else {
        Get.snackbar(
          'Update Failed',
          res['message']?.toString() ?? 'Failed to update status',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      updatingMemberStatusMap[member.id] = false;
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Update Member Multiple Cities
  Future<bool> updateCity(MemberItemModel member, String cities) async {
    try {
      final res = await _apiService.updateMemberCity(
        memberId: member.id,
        multipleCity: cities,
      );

      if (res['success'] == true) {
        member.multipleCity = cities;
        adminMembers.refresh();
        pendingAdminMembers.refresh();
        allMembers.refresh();
        pendingMembers.refresh();

        Get.snackbar(
          'Cities Updated',
          'Cities for ${member.name} updated successfully.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Failed',
          res['message']?.toString() ?? 'Failed to update cities',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Update Admin Member details
  Future<bool> updateAdmin({
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
      final res = await _apiService.updateAdminMember(
        adminId: adminId,
        name: name,
        gender: gender,
        email: email,
        userAddress: userAddress,
        userCurrentCity: userCurrentCity,
        mobile: mobile,
        faceImage: faceImage,
      );

      if (res['success'] == true) {
        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Admin updated successfully.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchAdminMembers();
        fetchPendingAdminMembers();
        return true;
      } else {
        Get.snackbar(
          'Update Failed',
          res['message']?.toString() ?? 'Failed to update admin profile',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  List<MemberItemModel> get filteredPendingMembers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return pendingMembers;
    return pendingMembers.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query);
    }).toList();
  }

  List<MemberItemModel> get filteredAllMembers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return allMembers;
    return allMembers.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query);
    }).toList();
  }

  /// Male members (Grooms)
  List<MemberItemModel> get maleMembers =>
      allMembers.where((m) => m.gender.toLowerCase() == 'male').toList();

  /// Female members (Brides)
  List<MemberItemModel> get femaleMembers =>
      allMembers.where((m) => m.gender.toLowerCase() == 'female').toList();

  /// Filtered Male Members (Grooms)
  List<MemberItemModel> get filteredMaleMembers {
    final query = searchQuery.value.trim().toLowerCase();
    final males = maleMembers;
    if (query.isEmpty) return males;
    return males.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      final gotra = m.gotraName?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query) || gotra.contains(query);
    }).toList();
  }

  /// Filtered Female Members (Brides)
  List<MemberItemModel> get filteredFemaleMembers {
    final query = searchQuery.value.trim().toLowerCase();
    final females = femaleMembers;
    if (query.isEmpty) return females;
    return females.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      final gotra = m.gotraName?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query) || gotra.contains(query);
    }).toList();
  }

  // Dashboard Stats Getters
  int get totalMembersCount => allMembers.length;
  int get pendingMembersCount => pendingMembers.length;
  int get maleCount => maleMembers.length;
  int get femaleCount => femaleMembers.length;
  int get adminCount => adminMembers.length;
  int get pendingAdminCount => pendingAdminMembers.length;
  int get approvedCount => allMembers.where((m) => m.status.toLowerCase() == 'approved').length;
  int get holdCount => allMembers.where((m) => m.status.toLowerCase() == 'hold').length;
  int get marriedCount => allMembers.where((m) => m.status.toLowerCase() == 'married').length;
  int get cancelCount => allMembers.where((m) => m.status.toLowerCase() == 'cancel').length;

  /// Full filtered candidates list taking into account search query, gender filter, and status filter
  List<MemberItemModel> get filteredCandidates {
    final query = searchQuery.value.trim().toLowerCase();
    final gender = selectedGenderFilter.value.toLowerCase();
    final status = selectedStatusFilter.value.toLowerCase();

    return allMembers.where((m) {
      // Gender filter
      if (gender != 'all' && m.gender.toLowerCase() != gender) {
        return false;
      }
      // Status filter
      if (status != 'all' && m.status.toLowerCase() != status) {
        return false;
      }
      // Search query
      if (query.isNotEmpty) {
        final name = m.name.toLowerCase();
        final mobile = m.mobile?.toLowerCase() ?? '';
        final city = m.userCurrentCity?.toLowerCase() ?? '';
        final gotra = m.gotraName?.toLowerCase() ?? '';
        final community = m.communityName?.toLowerCase() ?? '';
        final idStr = m.id.toString();
        final matches = name.contains(query) ||
            mobile.contains(query) ||
            city.contains(query) ||
            gotra.contains(query) ||
            community.contains(query) ||
            idStr == query;
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  /// Quick Approve convenience method
  Future<void> quickApprove(MemberItemModel member) async {
    await updateStatus(member, 'Approved');
  }

  List<MemberItemModel> get filteredPendingAdminMembers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return pendingAdminMembers;
    return pendingAdminMembers.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query);
    }).toList();
  }

  final RxString selectedOtherFilter = 'All'.obs; // 'All', 'Hold', 'Married', 'Cancel'

  /// Other members with non-active statuses (Hold, Married, Cancel)
  List<MemberItemModel> get otherMembers => allMembers.where((m) {
        final s = m.status.toLowerCase();
        return s == 'hold' || s == 'married' || s == 'cancel';
      }).toList();

  /// Filtered other members with search query & status filter
  List<MemberItemModel> get filteredOtherMembers {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedOtherFilter.value.toLowerCase();

    var list = otherMembers;
    if (filter != 'all') {
      list = list.where((m) => m.status.toLowerCase() == filter).toList();
    }

    if (query.isEmpty) return list;
    return list.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      final gotra = m.gotraName?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query) || gotra.contains(query);
    }).toList();
  }

  int get otherCount => otherMembers.length;

  List<MemberItemModel> get filteredAdminMembers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return adminMembers;
    return adminMembers.where((m) {
      final name = m.name.toLowerCase();
      final mobile = m.mobile?.toLowerCase() ?? '';
      final city = m.userCurrentCity?.toLowerCase() ?? '';
      return name.contains(query) || mobile.contains(query) || city.contains(query);
    }).toList();
  }

  Future<void> logout() async {
    await SessionManager.instance.destroySession();
  }
}
