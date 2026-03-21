import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';
import 'verification_screen.dart';

class SignedOutScreen extends StatefulWidget {
  const SignedOutScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  State<SignedOutScreen> createState() => _SignedOutScreenState();
}

class _SignedOutScreenState extends State<SignedOutScreen> {
  CountryCode _selectedCountry = CountryCode(code: 'ZM', dialCode: '+260');
  bool _agreedToTerms = true;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '961036382');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _openVerification() {
    final dialCode = _selectedCountry.dialCode ?? '+260';
    final phone = _phoneController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          phoneNumber: '$dialCode $phone',
          onVerified: widget.onSignIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const SizedBox(height: 36),
              Text(
                'Enter your phone number to start',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 52),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountryCodeSelector(
                    selected: _selectedCountry,
                    onChanged: (code) =>
                        setState(() => _selectedCountry = code),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _PhoneNumberField(controller: _phoneController),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _agreedToTerms
                            ? const Color(0xFFF97316)
                            : colorScheme.surface,
                        border: Border.all(
                          color: const Color(0xFFF97316),
                          width: 2.2,
                        ),
                      ),
                      child: _agreedToTerms
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: 'I agree to '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? _openVerification : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15A24),
                    disabledBackgroundColor: const Color(
                      0xFFF15A24,
                    ).withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    elevation: 0,
                    shadowColor: const Color(
                      0xFFF97316,
                    ).withValues(alpha: 0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Request code'),
                ),
              ),
              const SizedBox(height: 18),
              const Center(child: HomeIndicator()),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.onSurface, width: 1),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            cursorColor: colorScheme.onSurface,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class CountryCodeSelector extends StatelessWidget {
  const CountryCodeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: selected.code ?? 'ZM',
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          fontSize: AppTypography.size,
          fontWeight: FontWeight.w700,
        ),
        builder: (code) {
          final dial = code?.dialCode ?? selected.dialCode ?? '+260';
          final flagUri = code?.flagUri;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flagUri != null)
                Image.asset(
                  flagUri,
                  package: 'country_code_picker',
                  width: 32,
                  height: 20,
                  fit: BoxFit.cover,
                )
              else
                const Text(
                  '🌍',
                  style: TextStyle(fontSize: AppTypography.size),
                ),
              const SizedBox(width: 10),
              Text(
                dial,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface),
            ],
          );
        },
      ),
    );
  }
}
