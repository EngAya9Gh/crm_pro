import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../bloc/auth_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? token; // Can be passed from deep link

  const ResetPasswordScreen({super.key, this.email, this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final TextEditingController _tokenController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    if (widget.token != null) {
      _tokenController.text = widget.token!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      appBar: AppBar(
        title: const AppText(
          "إعادة تعيين كلمة المرور",
          style: TextStyle(color: AppColorScheme.textMain),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColorScheme.textMain,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColorScheme.success,
              ),
            );
            // Navigate reset to login, clearing stack
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthFailure) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                AppText(
                  "أنشئ كلمة مرور جديدة",
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 30),

                AppTextField(
                  controller: _emailController,
                  hintText: "البريد الإلكتروني",
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Token field usually hidden if passed via link, but visible for manual entry
                AppTextField(
                  controller: _tokenController,
                  hintText: "رمز التحقق (Token)",
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _passwordController,
                  hintText: "كلمة المرور الجديدة",
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                  validator: (val) =>
                      val!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _confirmPasswordController,
                  hintText: "تأكيد كلمة المرور",
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                  validator: (val) {
                    if (val != _passwordController.text)
                      return 'كلمات المرور غير متطابقة';
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: AppElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().resetPassword(
                              _emailController.text.trim(),
                              _passwordController.text,
                              _confirmPasswordController.text,
                              _tokenController.text.trim(),
                            );
                          }
                        },
                        text: "تغيير كلمة المرور",
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
