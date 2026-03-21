import 'package:flutter/material.dart';

import 'app_appearance_screen.dart';
import 'get_in_touch_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: GestureDetector(
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
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurface,
                    size: 25,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 34, 24, 26),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            _SettingsRow(
              icon: const _AppearanceIcon(),
              label: 'App appearance',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppAppearanceScreen()),
              ),
            ),
            _SettingsRow(
              icon: const _MessageIcon(),
              label: 'Get in touch',
              topBorder: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GetInTouchScreen()),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.topBorder = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: topBorder
              ? BorderSide(color: dividerColor, width: 1)
              : BorderSide.none,
          bottom: BorderSide(color: dividerColor, width: 1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Row(
            children: [
              SizedBox(width: 26, height: 26, child: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF9CA3AF),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceIcon extends StatelessWidget {
  const _AppearanceIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AppearanceIconPainter(
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF6B5B57),
      ),
    );
  }
}

class _AppearanceIconPainter extends CustomPainter {
  _AppearanceIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 6.5, stroke);

    const rays = [
      Offset(0, -11),
      Offset(0, 11),
      Offset(-11, 0),
      Offset(11, 0),
      Offset(-7.8, -7.8),
      Offset(7.8, -7.8),
      Offset(-7.8, 7.8),
      Offset(7.8, 7.8),
    ];
    for (final ray in rays) {
      final start = center + Offset(ray.dx * 0.72, ray.dy * 0.72);
      final end = center + ray;
      canvas.drawLine(start, end, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MessageIconPainter(
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF6B5B57),
      ),
    );
  }
}

class _MessageIconPainter extends CustomPainter {
  _MessageIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(4, 4)
      ..lineTo(22, 4)
      ..quadraticBezierTo(24, 4, 24, 6)
      ..lineTo(24, 18)
      ..quadraticBezierTo(24, 20, 22, 20)
      ..lineTo(10, 20)
      ..lineTo(5, 24)
      ..lineTo(5, 20)
      ..lineTo(4, 20)
      ..quadraticBezierTo(2, 20, 2, 18)
      ..lineTo(2, 6)
      ..quadraticBezierTo(2, 4, 4, 4)
      ..close();

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
