import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebasePhoneAuthService {
  FirebasePhoneAuthService._();

  static final FirebasePhoneAuthService instance = FirebasePhoneAuthService._();

  bool get isConfigured => Firebase.apps.isNotEmpty;

  Future<void> requestCode({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onFailed,
    required void Function(String verificationId) onAutoTimeout,
  }) async {
    if (!isConfigured) {
      onFailed(
        FirebaseAuthException(
          code: 'firebase-not-configured',
          message:
              'Firebase is not configured. Add google-services.json and GoogleService-Info.plist.',
        ),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoTimeout,
    );
  }

  Future<void> resendCode({
    required String phoneNumber,
    required int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onFailed,
    required void Function(String verificationId) onAutoTimeout,
  }) async {
    if (!isConfigured) {
      onFailed(
        FirebaseAuthException(
          code: 'firebase-not-configured',
          message:
              'Firebase is not configured. Add google-services.json and GoogleService-Info.plist.',
        ),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoTimeout,
    );
  }

  Future<void> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
