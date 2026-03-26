import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../services/firebase_phone_auth_service.dart';
import 'verification_screen.dart';

class SignedOutScreen extends StatefulWidget {
  const SignedOutScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  State<SignedOutScreen> createState() => _SignedOutScreenState();
}

class _SignedOutScreenState extends State<SignedOutScreen> {
  CountryCode _selectedCountry = CountryCode(code: 'US', dialCode: '+1');
  bool _isCreateAccount = false;
  bool _agreedToTerms = true;
  bool _isRequestingCode = false;
  bool _obscurePassword = true;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: '5550123');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _normalizePhoneNumber(String dialCode, String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$digits';
  }

  bool _isEmailValid(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String? _validateBeforeSubmit() {
    if (_isCreateAccount && _nameController.text.trim().isEmpty) {
      return context.tr(AppStrings.enterYourName);
    }

    if (_isCreateAccount && !_isEmailValid(_emailController.text.trim())) {
      return context.tr(AppStrings.enterValidEmail);
    }

    final normalizedPhone = _normalizePhoneNumber(
      _selectedCountry.dialCode ?? '+1',
      _phoneController.text.trim(),
    );
    final phoneDigits = normalizedPhone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 7) {
      return context.tr(AppStrings.enterPhoneNumberToContinue);
    }

    if (_passwordController.text.trim().length < 6) {
      return context.tr(AppStrings.passwordTooShort);
    }

    if (_isCreateAccount && !_agreedToTerms) {
      return context.tr(AppStrings.acceptTermsToContinue);
    }

    return null;
  }

  Future<void> _submit() async {
    final validationMessage = _validateBeforeSubmit();
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    final normalizedPhone = _normalizePhoneNumber(
      _selectedCountry.dialCode ?? '+1',
      _phoneController.text.trim(),
    );

    setState(() => _isRequestingCode = true);
    await FirebasePhoneAuthService.instance.requestCode(
      phoneNumber: normalizedPhone,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) {
          return;
        }
        setState(() => _isRequestingCode = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              phoneNumber: normalizedPhone,
              verificationId: verificationId,
              resendToken: resendToken,
              onVerified: widget.onSignIn,
            ),
          ),
        );
      },
      onFailed: (FirebaseAuthException error) {
        if (!mounted) {
          return;
        }
        setState(() => _isRequestingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
                  context.tr(AppStrings.failedToSendVerificationCode),
            ),
          ),
        );
      },
      onAutoTimeout: (_) {
        if (!mounted) {
          return;
        }
        setState(() => _isRequestingCode = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E10),
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 28),
                      _GlassHero(
                        title: context.tr(AppStrings.welcomeBackTitle),
                        subtitle: context.tr(AppStrings.authScreenSubtitle),
                      ),
                      const SizedBox(height: 28),
                      _AuthModeSelector(
                        isCreateAccount: _isCreateAccount,
                        onChanged: (value) =>
                            setState(() => _isCreateAccount = value),
                      ),
                      const SizedBox(height: 28),
                      _AuthFormCard(
                        isCreateAccount: _isCreateAccount,
                        selectedCountry: _selectedCountry,
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        agreedToTerms: _agreedToTerms,
                        isRequestingCode: _isRequestingCode,
                        onCountryChanged: (code) =>
                            setState(() => _selectedCountry = code),
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onToggleTerms: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        onSubmit: _submit,
                        onSwitchMode: () => setState(
                          () => _isCreateAccount = !_isCreateAccount,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.local_shipping_rounded, color: Color(0xFFF45C25), size: 30),
        SizedBox(width: 8),
        Text(
          'Roady GO',
          style: TextStyle(
            color: Color(0xFFF45C25),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

class _GlassHero extends StatelessWidget {
  const _GlassHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2023).withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFEEEEF0),
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFAAABAD),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthModeSelector extends StatelessWidget {
  const _AuthModeSelector({
    required this.isCreateAccount,
    required this.onChanged,
  });

  final bool isCreateAccount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF111416),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AuthModeButton(
            label: context.tr(AppStrings.logIn),
            selected: !isCreateAccount,
            onTap: () => onChanged(false),
          ),
          _AuthModeButton(
            label: context.tr(AppStrings.createAccount),
            selected: isCreateAccount,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF45C25) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF45C25).withValues(alpha: 0.32),
                    blurRadius: 22,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF000000) : const Color(0xFFAAABAD),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.isCreateAccount,
    required this.selectedCountry,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.agreedToTerms,
    required this.isRequestingCode,
    required this.onCountryChanged,
    required this.onTogglePassword,
    required this.onToggleTerms,
    required this.onSubmit,
    required this.onSwitchMode,
  });

  final bool isCreateAccount;
  final CountryCode selectedCountry;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool agreedToTerms;
  final bool isRequestingCode;
  final ValueChanged<CountryCode> onCountryChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleTerms;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isCreateAccount) ...[
          _FieldBlock(
            label: context.tr(AppStrings.fullName),
            child: _DarkAuthField(
              controller: nameController,
              hintText: context.tr(AppStrings.fullNameHint),
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 18),
          _FieldBlock(
            label: context.tr(AppStrings.emailAddress),
            child: _DarkAuthField(
              controller: emailController,
              hintText: context.tr(AppStrings.emailHint),
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 18),
        ],
        _FieldBlock(
          label: context.tr(AppStrings.phoneNumber),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CountryCodeSelector(
                selected: selectedCountry,
                onChanged: onCountryChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DarkAuthField(
                  controller: phoneController,
                  hintText: context.tr(AppStrings.phoneNumberHint),
                  prefixIcon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _FieldBlock(
          label: context.tr(AppStrings.password),
          child: _DarkAuthField(
            controller: passwordController,
            hintText: context.tr(AppStrings.passwordHint),
            prefixIcon: Icons.lock_person_rounded,
            obscureText: obscurePassword,
            suffix: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: const Color(0xFFAAABAD),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isCreateAccount)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggleTerms,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: agreedToTerms
                        ? const Color(0xFFF45C25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: agreedToTerms
                          ? const Color(0xFFF45C25)
                          : const Color(0xFF46484A),
                    ),
                  ),
                  child: agreedToTerms
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.black,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFFAAABAD),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: context.tr(AppStrings.iAgreeTo)),
                      TextSpan(
                        text: context.tr(AppStrings.termsAndConditions),
                        style: const TextStyle(
                          color: Color(0xFFEEEEF0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF906B),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                context.tr(AppStrings.forgotPassword),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isRequestingCode ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF45C25),
              disabledBackgroundColor: const Color(
                0xFFF45C25,
              ).withValues(alpha: 0.45),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: isRequestingCode
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.black,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCreateAccount
                            ? context.tr(AppStrings.createAccount)
                            : context.tr(AppStrings.logIn),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(
          width: 48,
          child: Divider(color: Color(0x3346484A), thickness: 1),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Text(
              isCreateAccount
                  ? context.tr(AppStrings.alreadyHaveAccount)
                  : context.tr(AppStrings.newHerePrompt),
              style: const TextStyle(
                color: Color(0xFFAAABAD),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: onSwitchMode,
              child: Text(
                isCreateAccount
                    ? context.tr(AppStrings.logIn)
                    : context.tr(AppStrings.createAccount),
                style: const TextStyle(
                  color: Color(0xFFEEEEF0),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFAAABAD),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DarkAuthField extends StatelessWidget {
  const _DarkAuthField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: const Color(0xFFAAABAD)),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              cursorColor: const Color(0xFFFF906B),
              style: const TextStyle(
                color: Color(0xFFEEEEF0),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF747578),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) ...[suffix!],
        ],
      ),
    );
  }
}

class _CountryCodeSelector extends StatelessWidget {
  const _CountryCodeSelector({required this.selected, required this.onChanged});

  final CountryCode selected;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: selected.code ?? 'US',
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          color: Color(0xFFEEEEF0),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        builder: (code) {
          final flagUri = code?.flagUri;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Color(0xFFFF906B),
                size: 22,
              ),
              if (flagUri != null) ...[
                const SizedBox(width: 10),
                Image.asset(
                  flagUri,
                  package: 'country_code_picker',
                  width: 24,
                  height: 16,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(width: 10),
              Text(code?.dialCode ?? selected.dialCode ?? '+1'),
            ],
          );
        },
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF0C0E10)),
        Positioned(
          top: -80,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF906B).withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -70,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF45C25).withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.95,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0C0E10).withValues(alpha: 0.92),
                  const Color(0xFF0C0E10),
                ],
                stops: const [0.0, 0.72, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
