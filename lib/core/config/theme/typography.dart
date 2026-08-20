import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_scheme.dart';
import '../../utils/responsive_helper.dart';

class AppTypography {
  // استخدام خط Tajawal للتطبيقات العربية الاحترافية مع دعم التصميم المتجاوب
  static TextStyle get displayLarge => GoogleFonts.tajawal(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.textMain,
  );

  static TextStyle get displayMedium => GoogleFonts.tajawal(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: AppColorScheme.textMain,
  );

  static TextStyle get titleLarge => GoogleFonts.tajawal(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.textMain,
  );

  static TextStyle get titleMedium => GoogleFonts.tajawal(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.textMain,
  );

  static TextStyle get titleSmall => GoogleFonts.tajawal(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.textMain,
  );

  static TextStyle get bodyLarge => GoogleFonts.tajawal(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.textMain,
  );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
    fontSize: 11.sp,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.textMain,
  );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
    fontSize: 10.sp,
    fontWeight: FontWeight.normal,
    color: AppColorScheme.textMuted,
  );

  static TextStyle get labelMedium => GoogleFonts.tajawal(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: AppColorScheme.textMuted,
  );

  static TextStyle get labelSmall => GoogleFonts.tajawal(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColorScheme.textMuted,
  );
}
