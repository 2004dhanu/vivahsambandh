import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_service.dart';
import '../../models/user_model.dart';
import 'firebase_notification_service.dart';
import '../../views/auth/otp_login_screen.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/user_home_controller.dart';
import '../../controllers/auth_controller.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyLoginLegacy = 'login';
  static const String keyUserSession = 'vivah_user_session';
  static const String keyAuthToken = 'vivah_auth_token';
  static const String keyUserRole = 'vivah_user_role';
  static const String keyUserDataLegacy = 'userData';

  /// Save active user session to persistent local storage
  Future<void> saveSession({
    required UserModel user,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Save flags
      await prefs.setBool(keyIsLoggedIn, true);
      await prefs.setBool(keyLoginLegacy, true);

      // 2. Save user profile json
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(keyUserSession, userJson);
      await prefs.setInt(keyUserRole, user.userType);

      // Also populate legacy userData map if necessary for older screens
      try {
        final legacyMap = {
          'code': 200,
          'msg': 'Success',
          'data': {
            'user': {
              'id': user.id,
              'name': user.name,
              'profile_main_contact_num': user.mobile,
              'profile_gender': user.gender,
              'profile_type': user.userType.toString(),
              'profile_full_face_photo_file_name': user.faceImage,
              'profile_present_city': user.userCurrentCity,
            },
            'token': token ?? ApiClient().authToken,
          }
        };
        await prefs.setString(keyUserDataLegacy, jsonEncode(legacyMap));
      } catch (_) {}

      // 3. Save and configure auth token
      if (token != null && token.isNotEmpty) {
        await prefs.setString(keyAuthToken, token);
        await ApiClient().setToken(token);
      }

      // 4. Configure FCM topic subscriptions
      try {
        await FirebaseNotificationService.instance.configureUserTopics(user);
      } catch (e) {
        debugPrint("⚠️ Failed to configure notification topics: $e");
      }

      debugPrint("✅ [SessionManager] Session successfully saved for ${user.name} (Role: ${user.roleName}, ID: ${user.id})");
    } catch (e) {
      debugPrint("❌ [SessionManager] Error saving session: $e");
    }
  }

  /// Get the currently logged-in user from persistent storage
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First try Vivah user session JSON
      final rawJson = prefs.getString(keyUserSession);
      if (rawJson != null && rawJson.trim().isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        return UserModel.fromJson(decoded);
      }

      // Fallback: Check legacy userData
      final legacyRaw = prefs.getString(keyUserDataLegacy);
      if (legacyRaw != null && legacyRaw.trim().isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(legacyRaw) as Map<String, dynamic>;
        final userObj = decoded['data']?['user'];
        if (userObj is Map<String, dynamic>) {
          return UserModel(
            id: int.tryParse(userObj['id']?.toString() ?? '0') ?? 0,
            name: userObj['name']?.toString() ?? '',
            mobile: userObj['profile_main_contact_num']?.toString() ?? '',
            gender: userObj['profile_gender']?.toString(),
            userType: int.tryParse(userObj['profile_type']?.toString() ?? '1') ?? 1,
            status: 'Approved',
            faceImage: userObj['profile_full_face_photo_file_name']?.toString(),
            userCurrentCity: userObj['profile_present_city']?.toString(),
            paymentDetails: decoded['payment_details'] ?? decoded['payments'] ?? decoded['data']?['payment_details'],
          );
        }
      }
    } catch (e) {
      debugPrint("❌ [SessionManager] Error reading user session: $e");
    }
    return null;
  }

  /// Check if an active session exists
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool loggedIn = prefs.getBool(keyIsLoggedIn) ?? prefs.getBool(keyLoginLegacy) ?? false;
      if (!loggedIn) return false;

      final user = await getUser();
      return user != null && user.id > 0;
    } catch (e) {
      debugPrint("❌ [SessionManager] Error checking login status: $e");
      return false;
    }
  }

  /// Retrieve stored bearer token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(keyAuthToken);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (_) {}
    return ApiClient().authToken;
  }

  /// Destroy the active session and redirect to login screen
  Future<void> destroySession({bool navigateToLogin = true}) async {
    debugPrint("🚪 [SessionManager] Destroying user session...");

    try {
      // 0. Remove device ID on CRM backend and unsubscribe from notification topics
      try {
        final user = await getUser();
        if (user != null) {
          try {
            await ApiService().removeDeviceId(user.id);
          } catch (e) {
            debugPrint("⚠️ removeDeviceId error on logout: $e");
          }
          await FirebaseNotificationService.instance.unsubscribeFromUserTopics(user);
        }
      } catch (_) {}

      // 1. Call server logout endpoint (best effort)
      try {
        await ApiService().logout();
      } catch (e) {
        debugPrint("⚠️ Server logout call error: $e");
      }

      // 2. Clear API client token
      await ApiClient().clearToken();

      // 3. Clear all stored session keys in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyIsLoggedIn);
      await prefs.remove(keyLoginLegacy);
      await prefs.remove(keyUserSession);
      await prefs.remove(keyUserRole);
      await prefs.remove(keyAuthToken);
      await prefs.remove(keyUserDataLegacy);

      // Explicitly set legacy login flag to false
      await prefs.setBool(keyLoginLegacy, false);
      await prefs.setBool(keyIsLoggedIn, false);

      // 4. Cleanup registered GetX controllers
      if (Get.isRegistered<AdminController>()) {
        Get.delete<AdminController>(force: true);
      }
      if (Get.isRegistered<UserHomeController>()) {
        Get.delete<UserHomeController>(force: true);
      }
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }

      debugPrint("✅ [SessionManager] Session destroyed successfully.");

      // 5. Navigate to OtpLoginScreen
      if (navigateToLogin) {
        Get.offAll(() => const OtpLoginScreen());
      }
    } catch (e) {
      debugPrint("❌ [SessionManager] Error during session destruction: $e");
      if (navigateToLogin) {
        Get.offAll(() => const OtpLoginScreen());
      }
    }
  }
}
