import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/common_widgets.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _emergencyPhoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '771406330');
    _nameController = TextEditingController(text: 'Chungu');
    _emailController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const _HeaderCircle(icon: Icons.close_rounded),
                      ),
                      const Spacer(),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: colorScheme.onSurface,
                          size: 34,
                        ),
                      ),
                      SizedBox(width: 24),
                      Text(
                        'Add a photo',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _CountrySelectorCard(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LabeledUnderlineInput(
                          label: 'Phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _LabeledUnderlineInput(
                    label: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 34),
                  _LabeledUnderlineInput(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'Email',
                    helperText:
                        'We\'ll send your trip summaries or invoices to this email',
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF111827)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned(right: -4, top: 6, child: _SosBadge()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 92),
                              child: Text(
                                'Emergency contact number (SOS button)',
                                style: TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const _CountrySelectorCard(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _LabeledUnderlineInput(
                                    label: '',
                                    controller: _emergencyPhoneController,
                                    keyboardType: TextInputType.phone,
                                    placeholder: 'Phone number',
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                  Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Delete my account',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 42),
                  GestureDetector(
                    onTap: widget.onLogout,
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: HomeIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 34,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _CountrySelectorCard extends StatelessWidget {
  const _CountrySelectorCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇿🇲', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            '+260',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _LabeledUnderlineInput extends StatelessWidget {
  const _LabeledUnderlineInput({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.placeholder,
    this.helperText,
    this.compact = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? placeholder;
  final String? helperText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
          cursorColor: colorScheme.onSurface,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: compact ? 19 : 20,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: placeholder,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.only(bottom: 8, top: 2),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onSurface, width: 1.5),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 12),
          Text(
            helperText!,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.slate,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SosBadge extends StatelessWidget {
  const _SosBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFE11D48),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x4DE11D48),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'SOS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
