import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../app/localization.dart';
import '../app/theme.dart';

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
  bool _obscureConfirmPassword = true;

  String? _phoneErrorText;
  String? _emailErrorText;
  String? _nameErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: '5550123');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _normalizePhoneNumber(String dialCode, String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$digits';
  }

  bool _isEmailValid(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _validateFields() {
    setState(() {
      _nameErrorText = null;
      _emailErrorText = null;
      _phoneErrorText = null;
      _passwordErrorText = null;
      _confirmPasswordErrorText = null;
    });

    bool isValid = true;

    if (_isCreateAccount && _nameController.text.trim().isEmpty) {
      setState(() => _nameErrorText = context.tr(AppStrings.enterYourName));
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailErrorText = 'Email address is required');
      isValid = false;
    } else if (!_isEmailValid(_emailController.text.trim())) {
      setState(() => _emailErrorText = context.tr(AppStrings.enterValidEmail));
      isValid = false;
    }

    if (_isCreateAccount) {
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _phoneErrorText = 'Phone number is required');
        isValid = false;
      } else {
        final normalizedPhone = _normalizePhoneNumber(
          _selectedCountry.dialCode ?? '+1',
          _phoneController.text.trim(),
        );
        try {
          final phoneNum = PhoneNumber.parse(normalizedPhone);
          if (!phoneNum.isValid(type: PhoneNumberType.mobile)) {
            setState(() => _phoneErrorText = 'Invalid phone number format for this country');
            isValid = false;
          }
        } catch (e) {
          setState(() => _phoneErrorText = 'Invalid phone number format for this country');
          isValid = false;
        }
      }
    }

    if (_passwordController.text.trim().length < 6) {
      setState(() => _passwordErrorText = context.tr(AppStrings.passwordTooShort));
      isValid = false;
    }

    if (_isCreateAccount && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordErrorText = context.tr(AppStrings.passwordsDoNotMatch);
        _confirmPasswordErrorText = context.tr(AppStrings.passwordsDoNotMatch);
      });
      isValid = false;
    }

    if (_isCreateAccount && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(AppStrings.acceptTermsToContinue))),
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> _submit() async {
    if (!_validateFields()) {
      return;
    }

    setState(() => _isRequestingCode = true);

    try {
      if (_isCreateAccount) {
        final normalizedPhone = _normalizePhoneNumber(
          _selectedCountry.dialCode ?? '+1',
          _phoneController.text.trim(),
        );

        final phoneNum = PhoneNumber.parse(normalizedPhone);
        final formattedPhone = phoneNum.international;

        // Check if phone number is already registered
        final usersRef = FirebaseFirestore.instance.collection('users');
        final querySnapshot =
            await usersRef.where('phoneNumber', isEqualTo: formattedPhone).get();
        if (querySnapshot.docs.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _isRequestingCode = false;
            _phoneErrorText = 'Phone number is already registered';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Phone number is already registered. Please log in.')),
          );
          return;
        }

        // Check if email already exists via FirebaseAuth or create user
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await usersRef.doc(user.uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phoneNumber': formattedPhone,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        if (!mounted) return;
        widget.onSignIn();
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        widget.onSignIn();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isRequestingCode = false;
        if (e.code == 'email-already-in-use') {
          _emailErrorText = 'Email is already registered. Please log in.';
        } else if (e.code == 'user-not-found') {
          _emailErrorText = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _passwordErrorText = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          _emailErrorText = 'Invalid email address.';
        } else {
          // Show general snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.message ??
                    context.tr(AppStrings.failedToSendVerificationCode))),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRequestingCode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRequestingCode = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 24),
                      _AuthModeSelector(
                        isCreateAccount: _isCreateAccount,
                        onChanged: (value) => setState(() {
                          _isCreateAccount = value;
                          _nameErrorText = null;
                          _emailErrorText = null;
                          _phoneErrorText = null;
                          _passwordErrorText = null;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 32),
                      _AuthFormCard(
                        isCreateAccount: _isCreateAccount,
                        selectedCountry: _selectedCountry,
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        agreedToTerms: _agreedToTerms,
                        isRequestingCode: _isRequestingCode,
                        isDark: isDark,
                        nameErrorText: _nameErrorText,
                        emailErrorText: _emailErrorText,
                        phoneErrorText: _phoneErrorText,
                        passwordErrorText: _passwordErrorText,
                        confirmPasswordErrorText: _confirmPasswordErrorText,
                        onCountryChanged: (code) =>
                            setState(() => _selectedCountry = code),
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onToggleConfirmPassword: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        ),
                        onToggleTerms: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        onSubmit: _submit,
                        onSwitchMode: () => setState(() {
                          _isCreateAccount = !_isCreateAccount;
                          _nameErrorText = null;
                          _emailErrorText = null;
                          _phoneErrorText = null;
                          _passwordErrorText = null;
                        }),
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
    return Image.asset(
      'assets/images/RoadyTaxi-image.png',
      width: MediaQuery.of(context).size.width * 0.7,
      fit: BoxFit.contain,
    );
  }
}

class _AuthModeSelector extends StatelessWidget {
  const _AuthModeSelector({
    required this.isCreateAccount,
    required this.onChanged,
    required this.isDark,
  });

  final bool isCreateAccount;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.cloud;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedColor = primary;
    final unselectedTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.slate;
    final selectedTextColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedTextColor : unselectedTextColor,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.agreedToTerms,
    required this.isRequestingCode,
    required this.isDark,
    this.nameErrorText,
    this.emailErrorText,
    this.phoneErrorText,
    this.passwordErrorText,
    this.confirmPasswordErrorText,
    required this.onCountryChanged,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
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
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreedToTerms;
  final bool isRequestingCode;
  final bool isDark;
  final String? nameErrorText;
  final String? emailErrorText;
  final String? phoneErrorText;
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final ValueChanged<CountryCode> onCountryChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onToggleTerms;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final cardColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : AppColors.cloud;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          if (isCreateAccount) ...[
            _FieldBlock(
              label: context.tr(AppStrings.fullName),
              child: _AuthField(
                controller: nameController,
                hintText: context.tr(AppStrings.fullNameHint),
                prefixIcon: Icons.person_outline_rounded,
                isDark: isDark,
                errorText: nameErrorText,
              ),
            ),
            const SizedBox(height: 20),
          ],
          _FieldBlock(
            label: context.tr(AppStrings.emailAddress),
            child: _AuthField(
              controller: emailController,
              hintText: context.tr(AppStrings.emailHint),
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
              errorText: emailErrorText,
            ),
          ),
          const SizedBox(height: 20),
          if (isCreateAccount) ...[
            _FieldBlock(
              label: context.tr(AppStrings.phoneNumber),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CountryCodeSelector(
                        selected: selectedCountry,
                        onChanged: onCountryChanged,
                        isDark: isDark,
                        hasError: phoneErrorText != null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AuthField(
                          controller: phoneController,
                          hintText: context.tr(AppStrings.phoneNumberHint),
                          prefixIcon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                          isDark: isDark,
                          errorText: phoneErrorText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _FieldBlock(
            label: context.tr(AppStrings.password),
            child: _AuthField(
              controller: passwordController,
              hintText: context.tr(AppStrings.passwordHint),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              isDark: isDark,
              errorText: passwordErrorText,
              suffix: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isCreateAccount) ...[
            _FieldBlock(
              label: context.tr(AppStrings.confirmPassword),
              child: _AuthField(
                controller: confirmPasswordController,
                hintText: context.tr(AppStrings.confirmPasswordHint),
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: obscureConfirmPassword,
                isDark: isDark,
                errorText: confirmPasswordErrorText,
                suffix: IconButton(
                  onPressed: onToggleConfirmPassword,
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
                      color: agreedToTerms ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: agreedToTerms
                            ? primary
                            : (isDark ? const Color(0xFF334155) : AppColors.cloud),
                        width: 1.5,
                      ),
                    ),
                    child: agreedToTerms
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        fontFamily: 'Satoshi',
                      ),
                      children: [
                        TextSpan(text: context.tr(AppStrings.iAgreeTo)),
                        TextSpan(
                          text: context.tr(AppStrings.termsAndConditions),
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.ink,
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
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isRequestingCode ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: primary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
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
                        strokeWidth: 2.5,
                        color: Colors.white,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.cloud,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : AppColors.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.cloud,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                isCreateAccount
                    ? context.tr(AppStrings.alreadyHaveAccount)
                    : context.tr(AppStrings.newHerePrompt),
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.isDark,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isDark;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDark ? const Color(0xFF020617) : AppColors.snow;
    final borderColor = isDark ? const Color(0xFF1E293B) : AppColors.cloud;
    final iconColor = isDark ? const Color(0xFF64748B) : AppColors.slate;
    final textColor = isDark ? Colors.white : AppColors.ink;
    final hintColor = isDark ? const Color(0xFF475569) : AppColors.slate.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: errorText != null ? theme.colorScheme.error : borderColor),
          ),
          child: Row(
            children: [
              Icon(prefixIcon, color: errorText != null ? theme.colorScheme.error : iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  cursorColor: theme.colorScheme.primary,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _CountryCodeSelector extends StatelessWidget {
  const _CountryCodeSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
    this.hasError = false,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onChanged;
  final bool isDark;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDark ? const Color(0xFF020617) : AppColors.snow;
    final borderColor = hasError ? theme.colorScheme.error : (isDark ? const Color(0xFF1E293B) : AppColors.cloud);
    final textColor = isDark ? Colors.white : AppColors.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: selected.code ?? 'US',
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        builder: (code) {
          final flagUri = code?.flagUri;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
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
                  code?.dialCode ?? selected.dialCode ?? '+1',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDark ? const Color(0xFF64748B) : AppColors.slate,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
