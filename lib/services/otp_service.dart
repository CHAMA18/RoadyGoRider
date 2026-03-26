import 'dart:math';

class OtpService {
  OtpService._();

  static final OtpService instance = OtpService._();

  final Map<String, String> _codesByPhone = {};

  String requestCode(String phoneNumber) {
    final code = _generateCode();
    _codesByPhone[phoneNumber] = code;
    return code;
  }

  String resendCode(String phoneNumber) {
    final code = _generateCode();
    _codesByPhone[phoneNumber] = code;
    return code;
  }

  bool verifyCode({required String phoneNumber, required String code}) {
    final stored = _codesByPhone[phoneNumber];
    return stored != null && stored == code;
  }

  String _generateCode() {
    final random = Random();
    return List.generate(4, (_) => random.nextInt(10)).join();
  }
}
