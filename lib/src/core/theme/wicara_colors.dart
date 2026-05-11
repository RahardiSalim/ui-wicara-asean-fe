import 'package:flutter/material.dart';

class WicaraColors {
  const WicaraColors._();

  static const ink = Color(0xFF252938);
  static const text = Color(0xFF343848);
  static const muted = Color(0xFF8E94A7);
  static const softMuted = Color(0xFFB8BECD);
  static const line = Color(0xFFE5E8F0);
  static const fieldFill = Color(0xFFFDFDFF);
  static const pageBackground = Color(0xFFFFFFFF);
  static const lavender = Color(0xFFBDA9F3);
  static const periwinkle = Color(0xFF7282EE);
  static const periwinkleDeep = Color(0xFF6375E7);
  static const mint = Color(0xFFDFF8EE);
  static const speechBlue = Color(0xFFE9E9FF);
  static const speechGreen = Color(0xFFEAF8F0);
  static const shadowBlue = Color(0xFFCFD7FF);

  static const primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [periwinkleDeep, lavender],
  );
}
