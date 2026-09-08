import 'dart:math' as math;

import 'package:flutter/material.dart';

class CricketLogo extends StatelessWidget {
  const CricketLogo({super.key, this.size = 96, this.muted = false});

  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final opacity = muted ? 0.6 : 1.0;
    return Opacity(
      opacity: opacity,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _CricketLogoPainter()),
      ),
    );
  }
}

class _CricketLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 108;
    canvas.scale(scale);

    final background = Paint()..color = const Color(0xFF78BFA7);
    final field = Paint()..color = const Color(0xFF15331F);
    final bat = Paint()..color = const Color(0xFFE9AF61);
    final batEdge = Paint()
      ..color = const Color(0xFF5D2E1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final helmet = Paint()..color = const Color(0xFF12382F);
    final helmetDark = Paint()..color = const Color(0xFF16191D);
    final grill = Paint()
      ..color = const Color(0xFFF4F0DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final red = Paint()..color = const Color(0xFFD3313C);
    final cream = Paint()..color = const Color(0xFFF8F4D8);

    canvas.drawCircle(const Offset(54, 54), 52, background);
    canvas.drawOval(const Rect.fromLTRB(10, 70, 96, 95), field);

    canvas.save();
    canvas.translate(12, 65);
    canvas.rotate(-0.16);
    final batPath = Path()
      ..moveTo(0, 8)
      ..quadraticBezierTo(3, 0, 12, 0)
      ..lineTo(88, 0)
      ..quadraticBezierTo(96, 1, 98, 8)
      ..lineTo(100, 17)
      ..lineTo(7, 20)
      ..quadraticBezierTo(0, 18, 0, 8)
      ..close();
    canvas.drawPath(batPath, bat);
    canvas.drawPath(batPath, batEdge);
    canvas.drawRect(
      const Rect.fromLTWH(11, 3, 32, 5),
      Paint()..color = const Color(0xFFFFD48A),
    );
    canvas.restore();

    final helmetPath = Path()
      ..moveTo(28, 45)
      ..cubicTo(29, 24, 47, 15, 67, 20)
      ..cubicTo(84, 24, 89, 36, 81, 50)
      ..lineTo(65, 59)
      ..lineTo(41, 59)
      ..cubicTo(33, 58, 28, 52, 28, 45)
      ..close();
    canvas.drawPath(helmetPath, helmet);
    canvas.drawPath(
      Path()
        ..moveTo(61, 21)
        ..cubicTo(76, 24, 86, 35, 81, 49)
        ..lineTo(64, 58)
        ..cubicTo(61, 45, 61, 33, 61, 21)
        ..close(),
      helmetDark,
    );
    canvas.drawArc(
      const Rect.fromLTRB(70, 39, 106, 59),
      math.pi,
      math.pi * 0.7,
      false,
      red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    canvas.drawLine(const Offset(40, 58), const Offset(93, 55), grill);
    canvas.drawLine(const Offset(48, 62), const Offset(92, 66), grill);
    canvas.drawLine(const Offset(59, 58), const Offset(72, 76), grill);
    canvas.drawLine(const Offset(75, 56), const Offset(83, 74), grill);
    canvas.drawLine(const Offset(90, 55), const Offset(94, 69), grill);

    canvas.drawCircle(const Offset(46, 85), 9, cream);
    canvas.drawCircle(const Offset(74, 83), 8, red..style = PaintingStyle.fill);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(46, 85), radius: 6),
      -1.3,
      2.4,
      false,
      Paint()
        ..color = const Color(0xFFD3313C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(74, 83), radius: 5),
      -1.0,
      2.2,
      false,
      Paint()
        ..color = cream.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.drawCircle(
      const Offset(39, 35),
      2.5,
      Paint()..color = const Color(0xFFFFC35B),
    );
    canvas.drawLine(
      const Offset(43, 32),
      const Offset(57, 27),
      Paint()
        ..color = const Color(0xFFFFC35B)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
