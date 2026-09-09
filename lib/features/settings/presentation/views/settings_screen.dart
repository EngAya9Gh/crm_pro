import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/common/widgets/app_drawer.dart';
import '../../../users/presentation/views/users_screen.dart';
import 'teams_screen.dart';
import 'roles_screen.dart';
import 'lookups_screen.dart';
import 'integrations_screen.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الإعدادات',
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'إدارة النظام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              title: 'الموظفين',
              subtitle: 'إدارة حسابات الموظفين وصلاحياتهم',
              icon: Icons.people_alt_rounded,
              color: AppColorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersScreen()),
              ),
            ),
            const SizedBox(height: 16),

            const AppText(
              'الهيكل التنظيمي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSettingsGridCard(
                    context,
                    title: 'الفرق',
                    subtitle: 'إدارة الفرق',
                    icon: Icons.groups_3_rounded,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamsScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSettingsGridCard(
                    context,
                    title: 'الأدوار',
                    subtitle: 'الصلاحيات',
                    icon: Icons.security_rounded,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RolesScreen()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const AppText(
              'تهيئة النظام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              title: 'القوائم المنسدلة (Lookups)',
              subtitle: 'المناطق، المدن، الحالات، المصادر...',
              icon: Icons.tune_rounded,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LookupsScreen()),
                );
              },
            ),
            if (context.hasPermission('settings.manage') && context.hasFeature('integrations')) ...[
              const SizedBox(height: 16),
              _buildSettingsCard(
                context,
                title: 'إعدادات الربط (Integrations)',
                subtitle: 'ربط المنصات الخارجية (Facebook, TikTok)',
                icon: Icons.hub_rounded,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IntegrationsScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColorScheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                AppText(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorScheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
