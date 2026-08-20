import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.textColor,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return animate
        ? _AnimatedLogo(size: size, showText: showText, textColor: textColor)
        : _StaticLogo(size: size, showText: showText, textColor: textColor);
  }
}

class _StaticLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const _StaticLogo({
    required this.size,
    required this.showText,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double itemSize = size * 0.42;
    final double spacing = size * 0.12;

    Widget logoGrid = SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShape(const Color(0xFF7A7A7A), itemSize, false),
              SizedBox(width: spacing),
              _buildShape(
                const Color(0xFFFF6B00),
                itemSize,
                true,
              ), // Orange Square
              // Grey Circle
            ],
          ),
          SizedBox(height: spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShape(const Color(0xFFFF6B00), itemSize, true),
              SizedBox(width: spacing),
              _buildShape(
                const Color(0xFF2C2E30),
                itemSize,
                false,
              ), // Dark Grey Circle
              // Orange Square
            ],
          ),
        ],
      ),
    );

    if (!showText) return logoGrid;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoGrid,
        const SizedBox(width: 12),
        AppText(
          "wakeel",
          style: AppTypography.displayLarge.copyWith(
            fontSize: size * 0.65,
            fontWeight: FontWeight.bold,
            color: textColor ?? AppColorScheme.textMain,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildShape(Color color, double size, bool isSquare) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(size * 0.35) : null,
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const _AnimatedLogo({
    required this.size,
    required this.showText,
    this.textColor,
  });

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slower animation
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.6 + (index * 0.1),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    // Increased delay to ensure native splash is gone and screen is rendered
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double itemSize = widget.size * 0.42;
    final double spacing = widget.size * 0.12;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget logoGrid = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedItem(
                    1,
                    const Color(0xFF7A7A7A),
                    itemSize,
                    false,
                  ),
                  SizedBox(width: spacing),
                  _buildAnimatedItem(
                    0,
                    const Color(0xFFFF6B00),
                    itemSize,
                    true,
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedItem(
                    3,
                    const Color(0xFFFF6B00),
                    itemSize,
                    true,
                  ),
                  SizedBox(width: spacing),

                  _buildAnimatedItem(
                    2,
                    const Color(0xFF2C2E30),
                    itemSize,
                    false,
                  ),
                ],
              ),
            ],
          ),
        );

        if (!widget.showText) return logoGrid;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            logoGrid,
            const SizedBox(width: 15),
            FadeTransition(
              opacity: _animations[3],
              child: AppText(
                "wakeel",
                style: AppTypography.displayLarge.copyWith(
                  fontSize: widget.size * 0.7,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor ?? AppColorScheme.textMain,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedItem(
    int index,
    Color color,
    double size,
    bool isSquare,
  ) {
    return ScaleTransition(
      scale: _animations[index],
      child: FadeTransition(
        opacity: _animations[index],
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isSquare ? BorderRadius.circular(size * 0.35) : null,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
