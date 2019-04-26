import 'dart:math';
import 'package:flutter/material.dart';

class ColorHelper {
  static String generateColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0)
        .value
        .toString();
  }
}
