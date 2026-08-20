import 'package:flutter/material.dart';

/// Wakeel CRM Color Palette
/// Based on the website visual identity
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFFF6600);
  static const Color primaryDark = Color(0xFFCC5200);
  static const Color primaryLight = Color(0xFFFF8533);
  static const Color primaryGlow = Color(0x40FF6600); // 25% opacity

  // Secondary Colors
  static const Color secondary = Color(0xFF171819);
  static const Color accent = Color(0xFF38BDF8);

  // Silver/Metallic
  static const Color silver = Color(0xFFCBD5E1);
  static const Color silverLight = Color(0xFFF1F5F9);

  // Backgrounds
  static const Color backgroundMain = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Text Colors
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Client Status Colors
  static const Color statusNew = Color(0xFF3B82F6);      // Blue
  static const Color statusNegotiation = Color(0xFFF59E0B); // Yellow
  static const Color statusQuotation = Color(0xFF8B5CF6);   // Purple
  static const Color statusExcluded = Color(0xFFEF4444);    // Red
  static const Color statusSubscribed = Color(0xFF22C55E); // Green

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF22C55E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [secondary, backgroundDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 20),
      blurRadius: 25,
    ),
  ];

  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: primaryGlow,
      offset: const Offset(0, 10),
      blurRadius: 20,
    ),
  ];
}
