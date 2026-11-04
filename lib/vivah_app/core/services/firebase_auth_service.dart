import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to user's mobile number
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    Function(String verificationId)? onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    try {
      debugPrint("🚀 Triggering Firebase Phone Auth for: $phoneNumber");

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("✅ Instant / Auto phone verification completed");
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("❌ Phone verification failed: ${e.code} - ${e.message}");
          String message = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            message = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many requests. Please try again later.';
          } else if (e.code == 'quota-exceeded') {
            message = 'SMS quota exceeded. Please contact support.';
          } else if (e.code == 'missing-client-identifier' ||
              e.code == 'captcha-check-failed' ||
              e.code == 'app-not-authorized') {
            message =
                'App verification failed (reCAPTCHA / Play Integrity). Please ensure SHA-1 & SHA-256 are added in Firebase Console.';
          } else if (e.message != null) {
            message = e.message!;
          }
          onVerificationFailed(message);
        },
        codeSent: (String verificationId, int? newResendToken) {
          debugPrint("📩 Code sent. VerificationId: $verificationId");
          onCodeSent(verificationId, newResendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("⏱️ Auto retrieval timeout for $verificationId");
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout(verificationId);
          }
        },
      );
    } catch (e) {
      debugPrint("❌ Error in sendOtp: $e");
      onVerificationFailed(e.toString());
    }
  }

  /// Verify OTP SMS code with verification ID
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException in verifyOtp: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Error verifying OTP: $e");
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
