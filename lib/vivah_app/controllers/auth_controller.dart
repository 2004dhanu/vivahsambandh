import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/api_client.dart';
import '../core/api/api_service.dart';
import '../core/services/firebase_auth_service.dart';
import '../core/services/firebase_notification_service.dart';
import '../core/services/session_manager.dart';
import '../models/user_model.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/auth/otp_verify_screen.dart';
import '../views/home/vivah_home_screen.dart';
import '../views/register/register_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ApiService _apiService = ApiService();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxString selectedCountryCode = '+91'.obs;
  final RxString verificationId = ''.obs;
  final RxnInt resendToken = RxnInt();
  final RxString serverOtpCode = ''.obs;
  final RxBool isExistingUser = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isOtpLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxInt selectedLoginMode = 1.obs; // OTP Login mode

  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  String get fullPhoneNumber =>
      '${selectedCountryCode.value}${phoneController.text.trim()}';

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void startResendTimer() {
    _timer?.cancel();
    countdown.value = 60;
    canResend.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// Mobile & Password Login (Handles User Type 1, 2: Admin, 3: Super Admin)
  Future<void> loginWithPassword() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your password.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final deviceToken = await FirebaseNotificationService.instance.getFcmToken();
      final res = await _apiService.appLogin(
        mobile: phone,
        password: password,
        deviceId: deviceToken,
      );

      isLoading.value = false;

      if (res['success'] == true) {
        final UserModel user = res['user'] as UserModel;
        final String? token = res['token']?.toString();

        // Persist session to local storage
        await SessionManager.instance.saveSession(user: user, token: token);

        Get.snackbar(
          'Login Successful',
          'Welcome back, ${user.name}!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        routeUserByRole(user);
      } else {
        Get.snackbar(
          'Login Failed',
          res['message']?.toString() ?? 'Invalid credentials. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Trigger sending OTP via Firebase with backend checkMobile synchronization
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // Check if the mobile is registered on the backend first
    try {
      final mobileCheck = await _apiService.checkMobile(phone);
      debugPrint("checkMobile response for $phone: code=${mobileCheck['code']}, msg=${mobileCheck['message']}");
      if (mobileCheck['code'] == 200 && mobileCheck['data'] != null) {
        serverOtpCode.value = mobileCheck['data'].toString();
        isExistingUser.value = true;
      } else if (mobileCheck['code'] == 404) {
        serverOtpCode.value = '';
        isExistingUser.value = false;
      }
    } catch (e) {
      debugPrint("Error checking mobile during sendOtp: $e");
    }

    await _authService.sendOtp(
      phoneNumber: fullPhoneNumber,
      resendToken: resendToken.value,
      onCodeSent: (String vId, int? token) {
        isLoading.value = false;
        verificationId.value = vId;
        resendToken.value = token;
        startResendTimer();

        Get.snackbar(
          'OTP Sent',
          'Verification code sent to $fullPhoneNumber',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.to(() => const OtpVerifyScreen());
      },
      onVerificationFailed: (String errorMessage) {
        isLoading.value = false;
        // If Firebase phone verification encounters network error/fails, but server code is available
        if (serverOtpCode.value.isNotEmpty) {
          startResendTimer();
          Get.snackbar(
            'Verification Required',
            'Please enter the 6-character code sent to proceed.',
            backgroundColor: const Color(0xFFC2185B),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          Get.to(() => const OtpVerifyScreen());
          return;
        }

        Get.snackbar(
          'Verification Failed',
          errorMessage,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        isLoading.value = false;
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Get.snackbar(
            'Success',
            'Phone number automatically verified!',
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          _navigateToNextStep();
        } catch (e) {
          debugPrint("Auto verify error: $e");
        }
      },
      onCodeAutoRetrievalTimeout: (String vId) {
        verificationId.value = vId;
      },
    );
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value) return;
    await sendOtp();
  }

  /// Verify entered Code
  Future<void> verifyOtp() async {
    final code = otpController.text.trim();
    if (code.isEmpty || code.length < 6) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the complete 6-character verification code.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isOtpLoading.value = true;

    // Check if entered code matches CRM server temporary verification code
    if (serverOtpCode.value.isNotEmpty &&
        code.toUpperCase() == serverOtpCode.value.toUpperCase()) {
      isOtpLoading.value = false;
      Get.snackbar(
        'Verified',
        'Mobile number successfully verified!',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      await _navigateToNextStep();
      return;
    }

    // Try verifying via Firebase Auth
    if (verificationId.value.isNotEmpty) {
      try {
        final userCredential = await _authService.verifyOtp(
          verificationId: verificationId.value,
          smsCode: code,
        );

        if (userCredential.user != null) {
          isOtpLoading.value = false;
          Get.snackbar(
            'Verified',
            'Mobile number successfully verified!',
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          await _navigateToNextStep();
          return;
        }
      } on FirebaseAuthException catch (e) {
        if (serverOtpCode.value.isNotEmpty &&
            code.toUpperCase() == serverOtpCode.value.toUpperCase()) {
          isOtpLoading.value = false;
          await _navigateToNextStep();
          return;
        }
        isOtpLoading.value = false;
        String msg = 'Incorrect code entered. Please check and try again.';
        if (e.message != null) msg = e.message!;
        Get.snackbar(
          'Verification Failed',
          msg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      } catch (e) {
        if (serverOtpCode.value.isNotEmpty &&
            code.toUpperCase() == serverOtpCode.value.toUpperCase()) {
          isOtpLoading.value = false;
          await _navigateToNextStep();
          return;
        }
        isOtpLoading.value = false;
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // If server code matched fallback
    if (serverOtpCode.value.isNotEmpty &&
        code.toUpperCase() == serverOtpCode.value.toUpperCase()) {
      isOtpLoading.value = false;
      await _navigateToNextStep();
      return;
    }

    isOtpLoading.value = false;
    Get.snackbar(
      'Verification Failed',
      'Session expired or incorrect code. Please try again.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Role-based screen navigation: User Type 1 -> User Home, User Type 2/3 -> Admin Dashboard
  void routeUserByRole(UserModel user) {
    if (user.isAdminOrSuperAdmin) {
      Get.offAll(() => AdminDashboardScreen(user: user));
    } else {
      Get.offAll(() => VivahHomeScreen(user: user));
    }
  }

  Future<void> _navigateToNextStep() async {
    _timer?.cancel();
    final phone = phoneController.text.trim();

    try {
      // 1. Direct login using the server OTP code if available from checkMobile
      String otpPass = serverOtpCode.value;
      if (otpPass.isEmpty) {
        final checkRes = await _apiService.checkMobile(phone);
        if (checkRes['code'] == 200 && checkRes['data'] != null) {
          otpPass = checkRes['data'].toString();
          serverOtpCode.value = otpPass;
          isExistingUser.value = true;
        } else if (checkRes['code'] == 404) {
          isExistingUser.value = false;
        }
      }

      if (otpPass.isNotEmpty) {
        final fcmToken = await FirebaseNotificationService.instance.getFcmToken();
        final loginRes = await _apiService.appLogin(
          mobile: phone,
          password: otpPass,
          deviceId: fcmToken,
        );

        if (loginRes['success'] == true && loginRes['user'] is UserModel) {
          final UserModel user = loginRes['user'] as UserModel;
          final String? token = loginRes['token']?.toString();

          await SessionManager.instance.saveSession(user: user, token: token);

          Get.snackbar(
            'Welcome Back',
            'Logged in successfully as ${user.name}',
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          routeUserByRole(user);
          return;
        }
      }

      // 2. Fallback check for existing member
      final existingMember = await _apiService.checkExistingMemberByMobile(phone);
      if (existingMember != null) {
        UserModel user = UserModel.fromMember(existingMember);
        final token = ApiClient().authToken;
        await SessionManager.instance.saveSession(user: user, token: token);

        Get.snackbar(
          'Welcome Back',
          'Logged in successfully as ${user.name}',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        routeUserByRole(user);
        return;
      }
    } catch (e) {
      debugPrint("Error checking existing user on OTP verify: $e");
    }

    // 3. Only if user is confirmed NOT registered, route to registration
    Get.offAll(() => RegisterScreen(verifiedMobile: phone));
  }
}
