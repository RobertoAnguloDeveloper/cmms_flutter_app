import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  
  const SignaturePad({
    Key? key,
    this.width = 300,
    this.height = 150,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: SignaturePainter(
            points: points,
            strokeColor: widget.strokeColor,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final double strokeWidth;

  SignaturePainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}