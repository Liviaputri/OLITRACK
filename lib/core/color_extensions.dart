import 'package:flutter/material.dart';

extension ColorOpacityExtension on Color {
  Color withOpacityValue(double opacity) {
    final int alpha = (opacity * 255).round().clamp(0, 255);
    return Color.fromARGB(alpha, r.round(), g.round(), b.round());
  }
}
