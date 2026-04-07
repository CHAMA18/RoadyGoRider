import 'package:flutter/material.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My addresses',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              // Add action
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom map and pin illustration
              const _MapIllustration(),
              const SizedBox(height: 32),
              const Text(
                'You have no saved addresses yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Add the words "Home" and "Work" to the addresses to be sure that you are ordering to the right place.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Add address action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF05A22), // Orange color from screenshot
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Offset to center content slightly higher
            ],
          ),
        ),
      ),
    );
  }
}

class _MapIllustration extends StatelessWidget {
  const _MapIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _MapIllustrationPainter(),
      ),
    );
  }
}

class _MapIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final orangePaint = Paint()
      ..color = const Color(0xFFF05A22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // Draw the map outline (folded map)
    final path = Path();
    
    // Bottom points
    final p1 = Offset(width * 0.1, height * 0.8);
    final p2 = Offset(width * 0.35, height * 0.9);
    final p3 = Offset(width * 0.65, height * 0.8);
    final p4 = Offset(width * 0.9, height * 0.85);

    // Top points
    final t1 = Offset(width * 0.25, height * 0.55);
    final t2 = Offset(width * 0.45, height * 0.6);
    final t3 = Offset(width * 0.75, height * 0.55);

    // Draw folded lines
    // Left fold
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(t2.dx, t2.dy);
    path.lineTo(t1.dx, t1.dy);
    path.close();

    // Middle fold
    path.moveTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.lineTo(t3.dx, t3.dy);
    path.lineTo(t2.dx, t2.dy);
    
    // Right fold
    path.moveTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);
    path.lineTo(t3.dx, t3.dy); // Right top edge isn't fully drawn in typical icons but we connect to t3
    // Wait, the rightmost top point is missing, let's add t4
    final t4 = Offset(width * 0.85, height * 0.65);
    path.moveTo(t3.dx, t3.dy);
    path.lineTo(t4.dx, t4.dy);
    path.lineTo(p4.dx, p4.dy);

    canvas.drawPath(path, paint);

    // Add some dashed lines for roads on the map
    _drawDashedLine(canvas, Offset(width * 0.2, height * 0.7), Offset(width * 0.3, height * 0.75), paint);
    _drawDashedLine(canvas, Offset(width * 0.5, height * 0.7), Offset(width * 0.6, height * 0.65), paint);
    _drawDashedLine(canvas, Offset(width * 0.75, height * 0.75), Offset(width * 0.85, height * 0.78), paint);

    // Draw the location pin
    final pinCenter = Offset(width * 0.5, height * 0.4);
    final pinPath = Path();
    pinPath.addArc(
      Rect.fromCircle(center: pinCenter, radius: width * 0.15),
      3.14,
      3.14,
    );
    // Right side of pin
    pinPath.quadraticBezierTo(
      width * 0.65, height * 0.55,
      width * 0.5, height * 0.7,
    );
    // Left side of pin
    pinPath.quadraticBezierTo(
      width * 0.35, height * 0.55,
      width * 0.35, height * 0.4,
    );
    canvas.drawPath(pinPath, paint);

    // Inner circle of pin
    canvas.drawCircle(pinCenter, width * 0.05, paint);

    // Orange signal waves on the sides
    // Left waves
    canvas.drawArc(
      Rect.fromCenter(center: pinCenter, width: width * 0.45, height: height * 0.45),
      3.14 * 0.8,
      3.14 * 0.4,
      false,
      orangePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: pinCenter, width: width * 0.6, height: height * 0.6),
      3.14 * 0.85,
      3.14 * 0.3,
      false,
      orangePaint,
    );

    // Right waves
    canvas.drawArc(
      Rect.fromCenter(center: pinCenter, width: width * 0.45, height: height * 0.45),
      -3.14 * 0.2,
      3.14 * 0.4,
      false,
      orangePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: pinCenter, width: width * 0.6, height: height * 0.6),
      -3.14 * 0.15,
      3.14 * 0.3,
      false,
      orangePaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var distance = (p2 - p1).distance;
    var direction = (p2 - p1) / distance;
    var start = p1;
    while (distance >= 0) {
      final end = start + direction * dashWidth;
      canvas.drawLine(start, end, paint);
      start = end + direction * dashSpace;
      distance -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
