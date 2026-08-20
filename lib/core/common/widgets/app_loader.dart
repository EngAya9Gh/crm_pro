import 'package:flutter/material.dart';
import '../../config/theme/color_scheme.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double? size;

  const AppLoader({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          color: color ?? AppColorScheme.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
