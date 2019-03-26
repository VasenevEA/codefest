import 'package:flutter/material.dart';

class Sky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(); 
    paint.color = Colors.yellow;
// create a path
var path = Path();
path.lineTo(300, 40);
path.lineTo(10, 4);
// close the path to form a bounded shape
  path.close();
  canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(Sky oldDelegate) {
    return false;
  }
}