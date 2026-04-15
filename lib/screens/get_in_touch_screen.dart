import 'package:flutter/material.dart';

import '../app/localization.dart';
import '../widgets/common_widgets.dart';

class GetInTouchScreen extends StatelessWidget {
  const GetInTouchScreen({super.key});

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
                          : const Color(0xFFE5E7EB),
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
              padding: EdgeInsets.fromLTRB(24, 34, 24, 20),
              child: Text(
                context.tr(AppStrings.getInTouch),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 54),
                    children: [
                      _ContactRow(
                        icon: const _PhoneIcon(),
                        label: context.tr(AppStrings.callUs),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ContactDetailScreen(
                                title: context.tr(AppStrings.callUs),
                              ),
                            ),
                          );
                        },
                      ),
                      const _ContactDivider(),
                      _ContactRow(
                        icon: const _MailIcon(),
                        label: context.tr(AppStrings.emailUs),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ContactDetailScreen(
                                title: context.tr(AppStrings.emailUs),
                              ),
                            ),
                          );
                        },
                      ),
                      const _ContactDivider(),
                    ],
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
          ],
        ),
      ),
    );
  }
}

class _ContactDivider extends StatelessWidget {
  const _ContactDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);
    return Padding(
      padding: EdgeInsets.only(left: 64),
      child: Divider(height: 1, thickness: 1, color: color),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, this.onTap});

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneIcon extends StatelessWidget {
  const _PhoneIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PhoneIconPainter(Theme.of(context).colorScheme.onSurface),
    );
  }
}

class _PhoneIconPainter extends CustomPainter {
  _PhoneIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(6, 3)
      ..quadraticBezierTo(4, 3, 4, 5)
      ..lineTo(4, 8)
      ..quadraticBezierTo(4, 10, 6, 10)
      ..lineTo(8, 10)
      ..lineTo(10, 15)
      ..quadraticBezierTo(12, 19, 16, 20)
      ..lineTo(19, 20)
      ..quadraticBezierTo(21, 20, 21, 18)
      ..lineTo(21, 15.5)
      ..quadraticBezierTo(21, 14, 19.5, 13.5)
      ..lineTo(15.5, 12)
      ..quadraticBezierTo(14, 11.5, 13, 12.8)
      ..lineTo(11.8, 14.2)
      ..quadraticBezierTo(10.6, 15.2, 9.3, 14)
      ..quadraticBezierTo(7.2, 11.8, 6, 8.8)
      ..quadraticBezierTo(5.2, 7, 6.2, 6)
      ..lineTo(7.7, 4.7)
      ..quadraticBezierTo(9, 3.6, 8.4, 2.4)
      ..lineTo(7.2, 3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MailIcon extends StatelessWidget {
  const _MailIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MailIconPainter(Theme.of(context).colorScheme.onSurface),
    );
  }
}

class _MailIconPainter extends CustomPainter {
  _MailIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 4, 19, 15),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);
    final path = Path()
      ..moveTo(4.5, 7)
      ..lineTo(12, 13)
      ..lineTo(19.5, 7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContactDetailScreen extends StatelessWidget {
  const _ContactDetailScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
