import 'package:flutter/material.dart';

import 'app_colors.dart';

class ReMindMark extends StatelessWidget {
  const ReMindMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ReMindMarkPainter()),
    );
  }
}

class _ReMindMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset(stroke, stroke) & Size(size.width - stroke * 2, size.height - stroke * 2);
    final loopPaint = Paint()
      ..shader = const LinearGradient(
        colors: [ReMindColors.sky, ReMindColors.mint],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -2.9, 5.2, false, loopPaint);

    final arrowPaint = Paint()
      ..color = ReMindColors.mint
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(size.width * 0.70, size.height * 0.80)
      ..lineTo(size.width * 0.90, size.height * 0.70)
      ..lineTo(size.width * 0.76, size.height * 0.56)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    final rPaint = Paint()
      ..color = ReMindColors.sky
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final rPath = Path()
      ..moveTo(size.width * 0.34, size.height * 0.68)
      ..lineTo(size.width * 0.34, size.height * 0.38)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.30, size.width * 0.44, size.height * 0.30)
      ..lineTo(size.width * 0.58, size.height * 0.30);
    canvas.drawPath(rPath, rPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
