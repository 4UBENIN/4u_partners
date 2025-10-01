import 'package:flutter/material.dart';

class DocumentsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const DocumentsIcon({
    Key? key,
    this.size = 24.0,
    this.color = const Color(0xFF333333),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DocumentsIconPainter(color: color),
    );
  }
}

class _DocumentsIconPainter extends CustomPainter {
  final Color color;

  _DocumentsIconPainter({this.color = const Color(0xFF333333)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw document outline
    final documentPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..lineTo(size.width * 0.6, size.height * 0.1)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.9)
      ..lineTo(size.width * 0.2, size.height * 0.9)
      ..close();

    // Draw fold corner
    final foldPath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.1)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.3);

    // Draw lines in the document
    final line1Path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.4);

    final line2Path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.7, size.height * 0.55);

    final line3Path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7);

    canvas.drawPath(documentPath, paint);
    canvas.drawPath(foldPath, paint);
    canvas.drawPath(line1Path, paint);
    canvas.drawPath(line2Path, paint);
    canvas.drawPath(line3Path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CarIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CarIcon({
    Key? key,
    this.size = 24.0,
    this.color = const Color(0xFF333333),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CarIconPainter(color: color),
    );
  }
}

class _CarIconPainter extends CustomPainter {
  final Color color;

  _CarIconPainter({this.color = const Color(0xFF333333)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Car body
    final carPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.15, size.height * 0.4)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..close();

    // Windows
    final windowPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.35)
      ..lineTo(size.width * 0.65, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.45)
      ..lineTo(size.width * 0.3, size.height * 0.45)
      ..close();

    // Wheels
    final leftWheel = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.7),
        radius: size.width * 0.1,
      ));

    final rightWheel = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.7),
        radius: size.width * 0.1,
      ));

    canvas.drawPath(carPath, paint);
    canvas.drawPath(windowPath, paint);
    canvas.drawPath(leftWheel, paint);
    canvas.drawPath(rightWheel, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
