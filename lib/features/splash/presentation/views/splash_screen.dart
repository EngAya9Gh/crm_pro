import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/common/widgets/app_logo.dart';
import 'package:crm_wakeel/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:crm_wakeel/features/auth/presentation/views/login_screen.dart';
import 'package:crm_wakeel/features/dashboard/presentation/views/dashboard_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isTimerDone = false;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // Keep splash for at least 4 seconds to show the animation
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
        if (_nextScreen != null) {
          _navigateTo(_nextScreen!);
        }
      }
    });
  }

  void _handleNavigation(Widget screen) {
    _nextScreen = screen;
    if (_isTimerDone) {
      _navigateTo(screen);
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _handleNavigation(const DashboardScreen());
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          _handleNavigation(const LoginScreen());
        }
      },
      child: Scaffold(
        backgroundColor: AppColorScheme.secondary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(
                size: 100,
                animate: true,
                textColor: AppColorScheme.white,
              ),
              const SizedBox(height: 12),
              AppText(
                "Advanced CRM Solution",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorScheme.silver,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
