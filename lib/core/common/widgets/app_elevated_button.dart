import 'package:flutter/material.dart';
import '../../config/theme/color_scheme.dart';
import '../../config/theme/typography.dart';
import 'app_loader.dart';
import 'app_text.dart';

class AppElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double width;

  const AppElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColorScheme.primary,
          foregroundColor: textColor ?? AppColorScheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: (backgroundColor ?? AppColorScheme.primary).withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: AppLoader(color: AppColorScheme.white, size: 24),
              )
            : AppText(
                text,
                style: AppTypography.titleMedium.copyWith(
                  color: textColor ?? AppColorScheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
