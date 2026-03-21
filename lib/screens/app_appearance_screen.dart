import 'package:flutter/material.dart';

import '../app/app.dart';
import '../widgets/common_widgets.dart';

class AppAppearanceScreen extends StatefulWidget {
  const AppAppearanceScreen({super.key});

  @override
  State<AppAppearanceScreen> createState() => _AppAppearanceScreenState();
}

class _AppAppearanceScreenState extends State<AppAppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final themeScope = RoadyGoRiderApp.of(context);
    final selectedMode = _AppearanceMode.fromThemeMode(themeScope.themeMode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF020617) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(28, 22, 28, 0),
              child: Text(
                'App appearance',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _AppearanceRow(
              title: 'Use device settings',
              textColor: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF1F2937),
              dividerColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE5E7EB),
              onTap: () => themeScope.setThemeMode(ThemeMode.system),
            ),
            _AppearanceRow(
              title: 'Light mode',
              textColor: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF1F2937),
              dividerColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE5E7EB),
              trailing: selectedMode == _AppearanceMode.light
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    )
                  : null,
              onTap: () => themeScope.setThemeMode(ThemeMode.light),
            ),
            _AppearanceRow(
              title: 'Dark mode',
              textColor: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF1F2937),
              trailing: selectedMode == _AppearanceMode.dark
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    )
                  : null,
              showDivider: false,
              onTap: () => themeScope.setThemeMode(ThemeMode.dark),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Center(child: HomeIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AppearanceMode {
  device,
  light,
  dark;

  static _AppearanceMode fromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return _AppearanceMode.device;
      case ThemeMode.light:
        return _AppearanceMode.light;
      case ThemeMode.dark:
        return _AppearanceMode.dark;
    }
  }
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({
    required this.title,
    this.trailing,
    this.showDivider = true,
    required this.onTap,
    required this.textColor,
    this.dividerColor = const Color(0xFFE5E7EB),
  });

  final String title;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback onTap;
  final Color textColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: dividerColor, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
