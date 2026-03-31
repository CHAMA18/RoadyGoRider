import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../services/firebase_phone_auth_service.dart';
import 'verification_screen.dart';

class SignedOutScreen extends StatefulWidget {
  const SignedOutScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  State<SignedOutScreen> createState() => _SignedOutScreenState();
}

class _SignedOutScreenState extends State<SignedOutScreen> {
  CountryCode _selectedCountry = CountryCode(code: 'ZM', dialCode: '+260');
  bool _agreedToTerms = false;
  bool _isRequestingCode = false;

  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhoneNumber(String dialCode, String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$digits';
  }

  Future<void> _submit() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    setState(() => _isRequestingCode = true);

    final normalizedPhone = _normalizePhoneNumber(
      _selectedCountry.dialCode ?? '+260',
      _phoneController.text.trim(),
    );

    try {
      final phoneNum = PhoneNumber.parse(normalizedPhone);
      if (!phoneNum.isValid(type: PhoneNumberType.mobile)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid phone number format')),
          );
          setState(() => _isRequestingCode = false);
        }
        return;
      }

      final formattedPhone = phoneNum.international;

      await FirebasePhoneAuthService.instance.requestCode(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => _isRequestingCode = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                phoneNumber: formattedPhone,
                verificationId: verificationId,
                resendToken: resendToken,
                onVerified: () {
                  Navigator.of(context).pop(); // pop verification screen
                  widget.onSignIn();
                },
              ),
            ),
          );
        },
        onFailed: (error) {
          if (!mounted) return;
          setState(() => _isRequestingCode = false);

          final isDomainError = error.code == 'unauthorized-domain' ||
              (error.message != null &&
                  error.message!.contains('Hostname match not found'));

          if (isDomainError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Domain not authorized. Proceeding with simulated flow for testing.'),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  phoneNumber: formattedPhone,
                  verificationId: 'dummy_verification_id',
                  resendToken: null,
                  onVerified: () {
                    Navigator.of(context).pop(); // pop verification screen
                    widget.onSignIn();
                  },
                ),
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  error.message ?? 'Failed to send verification code.'),
            ),
          );
        },
        onAutoTimeout: (verificationId) {
          // Can handle auto timeout here if needed
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRequestingCode = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number format')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryPeach = const Color(0xFFFDCBB8);
    final textPeach = const Color(0xFFE28B6B);
    final titleColor = isDark ? Colors.white : const Color(0xFF737373);
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your phone number to\nstart',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: CountryCodePicker(
                      onChanged: (code) {
                        setState(() => _selectedCountry = code);
                      },
                      initialSelection: _selectedCountry.code ?? 'ZM',
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      padding: EdgeInsets.zero,
                      builder: (code) {
                        final flagUri = code?.flagUri;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (flagUri != null) ...[
                                Image.asset(
                                  flagUri,
                                  package: 'country_code_picker',
                                  width: 24,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                code?.dialCode ?? _selectedCountry.dialCode ?? '+260',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF4B5563),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      cursorColor: textPeach,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: textPeach),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/RoadyTaxi-image.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreedToTerms = !_agreedToTerms;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _agreedToTerms
                            ? const Color(0xFFE28B6B)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _agreedToTerms
                              ? const Color(0xFFE28B6B)
                              : (isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFD1D5DB)),
                          width: 2,
                        ),
                      ),
                      child: _agreedToTerms
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'I agree to ',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_agreedToTerms && !_isRequestingCode)
                      ? _submit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPeach,
                    disabledBackgroundColor:
                        primaryPeach.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRequestingCode
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: textPeach,
                          ),
                        )
                      : Text(
                          'Request code',
                          style: TextStyle(
                            color: _agreedToTerms
                                ? textPeach
                                : textPeach.withValues(alpha: 0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
