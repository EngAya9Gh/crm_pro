import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/common/widgets/app_logo.dart';
import 'package:crm_wakeel/core/utils/app_strings.dart';
import 'package:crm_wakeel/features/dashboard/presentation/views/dashboard_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/features/auth/presentation/bloc/auth_cubit.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else if (state is AuthFailure) {
            print("UI Error Message: ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                // Added form for validation
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Header Image/Logo
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: const AppLogo(size: 80),
                      ),
                    ),
                    const SizedBox(height: 48),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "مرحباً بك مجدداً",
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            "قم بتسجيل الدخول للمتابعة",
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColorScheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    AppTextField(
                      controller: _emailController,
                      hintText: AppStrings.emailHint,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _passwordController,
                      hintText: AppStrings.passwordHint,
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: AppText(
                          "نسيت كلمة المرور؟",
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  // Basic validation
                                  context.read<AuthCubit>().login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: AppColorScheme.primary.withOpacity(0.3),
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : AppText(
                                AppStrings.login,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColorScheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
