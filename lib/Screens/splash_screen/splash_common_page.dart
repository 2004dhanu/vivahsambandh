import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../utils/const_helper.dart';
import '../../vivah_app/core/api/api_client.dart';
import '../../vivah_app/core/services/firebase_notification_service.dart';
import '../../vivah_app/core/services/session_manager.dart';
import '../../vivah_app/views/home/vivah_home_screen.dart';
import '../../vivah_app/views/admin/admin_dashboard_screen.dart';
import '../../vivah_app/views/auth/otp_login_screen.dart';

class SplashCommonPage extends StatefulWidget {
  const SplashCommonPage({super.key});

  @override
  State<SplashCommonPage> createState() => _SplashCommonPageState();
}

class _SplashCommonPageState extends State<SplashCommonPage> {
  HomeController homeController = Get.put(HomeController());
  Map<dynamic, dynamic> data = {};
  bool isSkip = false;

  //AppUpdateInfo? _updateInfo;
  // bool _flexibleUpdateAvailable = false;

  @override
  void initState() {
    // TODO: implement initState

    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
    super.initState();
  }

/*  Future<void> checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        startFlexibleUpdate();
      }
    } catch (e) {
      print("Error checking for updates: $e");
    }
  }

  // Start a flexible update
  Future<void> startFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
      print("Update installed successfully.");
    } catch (e) {
      print("Error during update: $e");
    }
  }*/
  Future<void> checkLogin() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      final bool loggedIn = await SessionManager.instance.isLoggedIn();
      if (!mounted) return;

      if (loggedIn) {
        final user = await SessionManager.instance.getUser();
        if (user != null) {
          final token = await SessionManager.instance.getToken();
          if (token != null && token.isNotEmpty) {
            await ApiClient().setToken(token);
          }
          try {
            FirebaseNotificationService.instance.configureUserTopics(user);
          } catch (_) {}

          if (user.isAdminOrSuperAdmin) {
            Get.offAll(() => AdminDashboardScreen(user: user));
          } else {
            Get.offAll(() => VivahHomeScreen(user: user));
          }
          return;
        }
      }

      Get.offAll(() => const OtpLoginScreen());
    } catch (e) {
      debugPrint("Error in checkLogin: $e");
      if (mounted) {
        Get.offAll(() => const OtpLoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstHelper.whiteColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/image/vs_app_logo.png",
                      height: Get.height * 0.16,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.025,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "vivah",
                      style: TextStyle(
                        fontSize: Get.height / 26,
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: "sambandh",
                          style: TextStyle(
                            fontSize: Get.height / 26,
                            color: const Color(0xFF880E4F),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Verified Profiles • Trusted Community",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: ConstHelper.premiumPinkGradient,
              ),
              child: const Text(
                "PREMIER MATRIMONIAL PLATFORM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            SizedBox(
              height: Get.height * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
