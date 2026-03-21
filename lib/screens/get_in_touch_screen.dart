import 'package:flutter/material.dart';

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
                'Get in touch',
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
                    children: const [
                      _ContactRow(icon: _PhoneIcon(), label: 'Call us'),
                      _ContactDivider(),
                      _ContactRow(icon: _MailIcon(), label: 'Email us'),
                      _ContactDivider(),
                      _ContactRow(
                        icon: _InfoIcon(),
                        label: 'Get legal information',
                      ),
                      _ContactDivider(),
                      _ContactRow(icon: _FacebookIcon(), label: 'Facebook'),
                      _ContactDivider(),
                      _ContactRow(icon: _InstagramIcon(), label: 'Instagram'),
                      _ContactDivider(),
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
  const _ContactRow({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
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

class _InfoIcon extends StatelessWidget {
  const _InfoIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InfoIconPainter(Theme.of(context).colorScheme.onSurface),
    );
  }
}

class _InfoIconPainter extends CustomPainter {
  _InfoIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(const Offset(12, 12), 9, stroke);
    canvas.drawLine(const Offset(12, 10), const Offset(12, 16), stroke);
    canvas.drawCircle(const Offset(12, 7), 1.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'f',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InstagramIconPainter(Theme.of(context).colorScheme.onSurface),
    );
  }
}

class _InstagramIconPainter extends CustomPainter {
  _InstagramIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final outer = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.5, 2.5, 19, 19),
      const Radius.circular(5),
    );
    canvas.drawRRect(outer, paint);
    canvas.drawCircle(const Offset(12, 12), 4.5, paint);
    canvas.drawCircle(const Offset(17.2, 6.8), 1, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
