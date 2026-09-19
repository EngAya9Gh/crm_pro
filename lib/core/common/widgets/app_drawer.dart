import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/utils/app_strings.dart';
import 'package:crm_wakeel/core/common/widgets/app_logo.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:crm_wakeel/features/clients/presentation/views/clients_screen.dart';
import 'package:crm_wakeel/features/clients/presentation/views/clients_stats_screen.dart';
import 'package:crm_wakeel/features/clients/presentation/views/clients_kpi_screen.dart';
import 'package:crm_wakeel/features/invoices/presentation/views/invoices_screen.dart';
import 'package:crm_wakeel/features/appointments/presentation/views/appointments_screen.dart';
import 'package:crm_wakeel/features/settings/presentation/views/settings_screen.dart';
import 'package:crm_wakeel/features/settings/presentation/views/roles_screen.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:crm_wakeel/features/auth/presentation/views/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColorScheme.background,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: AppListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  context,
                  title: AppStrings.dashboard,
                  icon: Icons.grid_view_rounded,
                  destination: const DashboardScreen(),
                  isActive: true,
                ),
                if (context.hasPermission('clients.view') &&
                    context.hasFeature('clients'))
                  _buildExpandableClientsMenu(context),
                if (context.hasPermission('invoices.view') &&
                    context.hasFeature('invoices'))
                  _buildMenuItem(
                    context,
                    title: AppStrings.invoices,
                    icon: Icons.receipt_long_outlined,
                    destination: const InvoicesScreen(),
                  ),
                if (context.hasPermission('appointments.view') &&
                    context.hasFeature('appointments'))
                  _buildMenuItem(
                    context,
                    title: AppStrings.appointments,
                    icon: Icons.event_note_rounded,
                    destination: const AppointmentsScreen(),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: AppColorScheme.surface, thickness: 2),
                ),
                if ((context.hasPermission('settings.view') ||
                        context.hasPermission('users.view') ||
                        context.hasPermission('teams.view')) &&
                    context.hasFeature('settings'))
                  _buildMenuItem(
                    context,
                    title: AppStrings.settings,
                    icon: Icons.settings_outlined,
                    destination: const SettingsScreen(),
                  ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String name = "مستخدم";
    String email = "";
    String roleName = "";
    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      email = authState.user.email;
      roleName = authState.user.role.name;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColorScheme.secondary, AppColorScheme.secondaryLight],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using Reusable AppLogo
          const AppLogo(size: 35, textColor: AppColorScheme.white),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=FF8533&color=fff',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      name,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColorScheme.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (roleName.isNotEmpty)
                      AppText(
                        roleName,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColorScheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    AppText(
                      email,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColorScheme.silver,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableClientsMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColorScheme.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: AppText(
            AppStrings.clients,
            style: AppTypography.titleMedium.copyWith(fontSize: 16),
          ),
          leading: const Icon(
            Icons.people_outline_rounded,
            color: AppColorScheme.textMuted,
          ),
          childrenPadding: const EdgeInsets.only(right: 32),
          children: [
            _buildSubMenuItem(
              context,
              title: 'قائمة العملاء',
              destination: const ClientsScreen(),
            ),
            _buildSubMenuItem(
              context,
              title: 'الإحصائيات',
              destination: const ClientsStatsScreen(),
            ),
            _buildSubMenuItem(
              context,
              title: 'مؤشرات الأداء',
              destination: const ClientsKPIScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        if (destination is DashboardScreen) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => route.isFirst,
          );
        }
      },
      title: AppText(
        title,
        style: AppTypography.bodySmall.copyWith(fontSize: 14),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget? destination,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColorScheme.primary.withOpacity(0.08)
            : AppColorScheme.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {
          if (destination != null) {
            Navigator.pop(context);
            if (destination is DashboardScreen) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => destination),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => destination),
                (route) => route.isFirst,
              );
            }
          }
        },
        leading: Icon(
          icon,
          color: isActive ? AppColorScheme.primary : AppColorScheme.textMuted,
          size: 24,
        ),
        title: AppText(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 16,
            color: isActive ? AppColorScheme.primary : AppColorScheme.textMain,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: InkWell(
        onTap: () async {
          // عرض شاشة تحميل بسيطة وأنيقة
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppText(
                      'جاري تسجيل الخروج...',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColorScheme.textMain,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          await context.read<AuthCubit>().logout();

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColorScheme.error.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AppColorScheme.error),
              const SizedBox(width: 12),
              AppText(
                "تسجيل الخروج",
                style: AppTypography.titleMedium.copyWith(
                  color: AppColorScheme.error,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
