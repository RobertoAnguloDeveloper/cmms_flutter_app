import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onPanDown: (DragDownDetails details) {
            setState(() {
              _currentStroke = [details.localPosition];
              _strokes.add(_currentStroke!);
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              _currentStroke?.add(details.localPosition);
              _strokes.last = List.from(_currentStroke!);
            });
          },
          onPanEnd: (DragEndDetails details) {
            _currentStroke = null;
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: SignaturePainter(strokes: _strokes),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final List<Offset> stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}