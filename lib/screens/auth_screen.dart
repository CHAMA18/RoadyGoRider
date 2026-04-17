import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app/theme.dart';

class SignedOutScreen extends StatefulWidget {
  const SignedOutScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  State<SignedOutScreen> createState() => _SignedOutScreenState();
}

class _SignedOutScreenState extends State<SignedOutScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isLogin = !_isLogin;
        });
        _animationController.forward();
      }
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        (!_isLogin && confirmPassword.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (!_isLogin && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_isLogin && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions and Privacy Policy')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      if (mounted) {
        widget.onSignIn();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'Authentication failed';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.brand,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: AppColors.brand,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final provider = GoogleAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }
      if (mounted) {
        widget.onSignIn();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final provider = OAuthProvider('apple.com');
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }
      if (mounted) {
        widget.onSignIn();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple Sign-In failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.ink;
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF);
    final inputBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Content scroll view
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top area for logo
                            SizedBox(
                              height: constraints.maxHeight * 0.35,
                              child: Center(
                                child: Hero(
                                  tag: 'vunigo_logo',
                                  child: Image.asset(
                                    'assets/images/Vunigo_logo_white.png',
                                    width: 160,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox(height: 160),
                                  ),
                                ),
                              ),
                            ),
                            // Bottom area for form
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                      offset: const Offset(0, -5),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 40),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _isLogin
                                                  ? 'Welcome back'
                                                  : 'Create account',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: textColor,
                                                height: 1.2,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _isLogin
                                                  ? 'Enter your details to sign in.'
                                                  : 'Sign up to get started.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: hintColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: 'Email address',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        textColor: textColor,
                                        hintColor: hintColor,
                                        bgColor: inputBgColor,
                                        borderColor: borderColor,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _passwordController,
                                        hintText: 'Password',
                                        icon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        textColor: textColor,
                                        hintColor: hintColor,
                                        bgColor: inputBgColor,
                                        borderColor: borderColor,
                                        isDark: isDark,
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                              size: 22,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      if (!_isLogin) ...[
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _confirmPasswordController,
                                          hintText: 'Confirm Password',
                                          icon: Icons.lock_outline,
                                          obscureText: _obscureConfirmPassword,
                                          textColor: textColor,
                                          hintColor: hintColor,
                                          bgColor: inputBgColor,
                                          borderColor: borderColor,
                                          isDark: isDark,
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                                size: 22,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      !_obscureConfirmPassword;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (_isLogin) ...[
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Reset password flow not implemented.')),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.brand,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            child: const Text('Forgot password?'),
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: _agreedToTerms,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _agreedToTerms = val ?? false;
                                                  });
                                                },
                                                activeColor: AppColors.brand,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                side: BorderSide(color: hintColor),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text.rich(
                                                TextSpan(
                                                  text: 'By signing up, you agree to our ',
                                                  style: TextStyle(
                                                    color: hintColor,
                                                    fontSize: 14,
                                                    height: 1.5,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: 'Terms & Conditions',
                                                      style: TextStyle(
                                                        color: AppColors.brand,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const TextSpan(text: ' and '),
                                                    TextSpan(
                                                      text: 'Privacy Policy',
                                                      style: TextStyle(
                                                        color: AppColors.brand,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.brand,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                AppColors.brand.withValues(alpha: 0.5),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Text(
                                                  _isLogin
                                                      ? 'Sign In'
                                                      : 'Sign Up',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Divider(color: borderColor)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              'OR',
                                              style: TextStyle(
                                                color: hintColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Divider(color: borderColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _isLoading
                                                  ? null
                                                  : _signInWithGoogle,
                                              icon: const Text(
                                                'G',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              label: Text(
                                                'Google',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 16),
                                                side: BorderSide(
                                                    color: borderColor,
                                                    width: 1.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _isLoading
                                                  ? null
                                                  : _signInWithApple,
                                              icon: Icon(
                                                Icons.apple,
                                                color: textColor,
                                                size: 24,
                                              ),
                                              label: Text(
                                                'Apple',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 16),
                                                side: BorderSide(
                                                    color: borderColor,
                                                    width: 1.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isLogin
                                                ? "Don't have an account? "
                                                : "Already have an account? ",
                                            style: TextStyle(
                                              color: hintColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _isLoading ? null : _toggleMode,
                                            child: Text(
                                              _isLogin ? 'Sign up' : 'Sign in',
                                              style: TextStyle(
                                                color: _isLoading
                                                    ? hintColor
                                                    : AppColors.brand,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SafeArea(
                                        top: false,
                                        child: SizedBox(height: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required Color textColor,
    required Color hintColor,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final focusColor = AppColors.brand;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: obscureText ? TextInputAction.done : TextInputAction.next,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 48),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: focusColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
