import 'package:flutter/material.dart';

class AppColorScheme {
  // Brand Colors from Logo
  static const Color primary = Color(0xFFFF6600); // Wakeel Orange
  static const Color primaryDark = Color(0xFFD35400);
  static const Color primaryLight = Color(0xFFFF8533);

  static const Color secondary = Color(0xFF171819); // Rich Black
  static const Color secondaryLight = Color(0xFF2C2C2E);

  static const Color silver = Color(0xFF8E8E93); // Metallic Silver
  static const Color silverLight = Color(0xFFC7C7CC);
  static const Color silverDark = Color(0xFF48484A);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF2F2F7);
  static const Color card = Color(0xFFFFFFFF);

  // Standard Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Text Colors
  static const Color textMain = Color(0xFF1C1C1E);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);
  static const Color info = Color(0xFF007AFF);

  // Aliases for compatibility
  static const Color textPrimary = textMain;
  static const Color accent = info;
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color glassWhite = Color(0xCCFFFFFF);
}
