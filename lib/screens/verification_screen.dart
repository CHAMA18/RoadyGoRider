import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../services/firebase_phone_auth_service.dart';
import '../widgets/common_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.resendToken,
    required this.onVerified,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final VoidCallback onVerified;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _initialCountdownSeconds = 14 * 60 + 33;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _countdownTimer;
  late String _verificationId;
  int? _resendToken;
  bool _isVerifying = false;
  int _secondsRemaining = _initialCountdownSeconds;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        setState(() => _secondsRemaining = 0);
        timer.cancel();
        return;
      }

      setState(() => _secondsRemaining -= 1);
    });
  }

  Future<void> _resendCode() async {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    await FirebasePhoneAuthService.instance.resendCode(
      phoneNumber: widget.phoneNumber,
      resendToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) {
          return;
        }
        _verificationId = verificationId;
        _resendToken = resendToken;
        setState(() => _secondsRemaining = _initialCountdownSeconds);
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                AppStrings.resendCodeConfirmation,
                params: {'phone': widget.phoneNumber},
              ),
            ),
          ),
        );
      },
      onFailed: (FirebaseAuthException error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
                  'Failed to send verification code. Check Firebase setup.',
            ),
          ),
        );
      },
      onAutoTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _handleCodeChanged(int index, String value) async {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _controllers.map((controller) => controller.text).join();
    if (code.length == 4 && !_isVerifying) {
      setState(() => _isVerifying = true);
      try {
        await FirebasePhoneAuthService.instance.verifyCode(
          verificationId: _verificationId,
          smsCode: code,
        );
        if (!mounted) {
          return;
        }
        widget.onVerified();
      } on FirebaseAuthException catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Incorrect verification code.'),
          ),
        );
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes.first.requestFocus();
      } finally {
        if (mounted) {
          setState(() => _isVerifying = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.18 : 0.06,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _ResendTimer(
                        secondsRemaining: _secondsRemaining,
                        onResend: _resendCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Text(
                    context.tr(AppStrings.codeSentTo),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      color: Color(0xFFFF5C1A),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 44),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => _OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _handleCodeChanged(index, value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(child: HomeIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResendTimer extends StatelessWidget {
  const _ResendTimer({required this.secondsRemaining, required this.onResend});

  final int secondsRemaining;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countdownColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF9CA3AF);

    if (secondsRemaining == 0) {
      return TextButton(
        onPressed: onResend,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF5C1A),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          context.tr(AppStrings.sendCodeAgain),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );
    }

    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      context.tr(AppStrings.sendAgainIn, params: {'time': formattedTime}),
      style: TextStyle(
        color: countdownColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 60,
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
