import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

extension PermissionExtension on BuildContext {
  /// يتحقق مما إذا كان المستخدم يمتلك الصلاحية المطلوبة بسرعة البرق O(1)
  bool hasPermission(String permission) {
    try {
      final authState = read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        print('Checking permission: $permission');
        print('User permissions: ${authState.user.permissions}');
        // البحث في Set سريع جداً O(1)
        return authState.user.permissions.contains(permission);
      }
    } catch (_) {
      // إذا لم يكن الـ AuthCubit متاحاً في السياق الحالي
    }
    return false;
  }

  /// يتحقق مما إذا كان المستأجر (Tenant) يملك الميزة المطلوبة (مثلاً: whatsapp, invoices)
  bool hasFeature(String feature) {
    try {
      final authState = read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final tenant = authState.user.tenant;
        if (tenant != null) {
          return tenant.enabledFeatures.contains(feature);
        }
      }
    } catch (_) {
      // إذا لم يكن الـ AuthCubit متاحاً في السياق الحالي
    }
    return false;
  }
}
