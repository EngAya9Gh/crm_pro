import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_dropdown.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../../domain/entities/lookup_entities.dart';
import '../bloc/lookups_bloc.dart';
import '../bloc/lookups_event.dart';
import '../bloc/lookups_state.dart';
import '../bloc/settings_crud_bloc.dart';
import '../bloc/settings_crud_event.dart';
import '../bloc/settings_crud_state.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LookupsBloc>()..add(LoadAllLookups())),
        BlocProvider(create: (_) => getIt<SettingsCrudBloc>()),
      ],
      child: const RolesView(),
    );
  }
}

class RolesView extends StatelessWidget {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الأدوار الوظيفية',
      actions: [
        IconButton(
          onPressed: () => _showAddEditRoleDialog(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: AppColorScheme.primary),
          ),
        ),
      ],
      body: BlocListener<SettingsCrudBloc, SettingsCrudState>(
        listener: (context, state) {
          if (state is SettingsCrudSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColorScheme.success,
              ),
            );
            context.read<LookupsBloc>().add(LoadAllLookups());
          } else if (state is SettingsCrudFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<LookupsBloc, LookupsState>(
          builder: (context, state) {
            if (state is LookupsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LookupsLoaded) {
              final roles = state.lookups.roles;
              if (roles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 80,
                        color: AppColorScheme.textMuted.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const AppText(
                        'لا توجد أدوار مضافة',
                        style: TextStyle(color: AppColorScheme.textMuted),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return _buildRoleCard(context, role);
                },
              );
            }
            return const Center(child: AppText('حدث خطأ في تحميل البيانات'));
          },
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, RoleEntity role) {
    final permCount = role.permissions.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          onTap: () => _showAddEditRoleDialog(context, role: role),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        role.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColorScheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.vpn_key_outlined,
                                  size: 14,
                                  color: AppColorScheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                AppText(
                                  '$permCount صلاحيات',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColorScheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context, role),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RoleEntity role) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showAddEditRoleDialog(context, role: role),
          style: IconButton.styleFrom(
            backgroundColor: AppColorScheme.info.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
          ),
          icon: const Icon(
            Icons.edit_rounded,
            color: AppColorScheme.info,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _confirmDelete(context, role),
          style: IconButton.styleFrom(
            backgroundColor: AppColorScheme.error.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
          ),
          icon: const Icon(
            Icons.delete_rounded,
            color: AppColorScheme.error,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _showAddEditRoleDialog(BuildContext context, {RoleEntity? role}) {
    final nameController = TextEditingController(text: role?.name ?? '');
    final isEditing = role != null;

    // Get lookups state
    final lookupsState = context.read<LookupsBloc>().state;
    List<PermissionEntity> allPermissions = [];
    List<TeamEntity> teams = [];

    if (lookupsState is LookupsLoaded) {
      allPermissions = lookupsState.lookups.permissions;
      teams = lookupsState.lookups.teams;
    }

    TeamEntity? selectedTeam;
    if (isEditing && role.teamId != null) {
      try {
        selectedTeam = teams.firstWhere((t) => t.id == role.teamId);
      } catch (_) {}
    }

    // Initialize selected permissions
    final Set<int> selectedPermissionIds = isEditing
        ? role.permissions.map((p) => p.id).toSet()
        : <int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_rounded : Icons.add_rounded,
                            color: AppColorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        AppText(
                          isEditing ? 'تعديل الدور' : 'إضافة دور جديد',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'بيانات الدور',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: nameController,
                            hintText: 'اسم الدور الوظيفي',
                            label: 'الاسم',
                          ),
                          const SizedBox(height: 24),
                          if (teams.isNotEmpty) ...[
                            AppDropdown<TeamEntity>(
                              label: 'الفريق التابع له',
                              hint: 'اختر الفريق',
                              value: selectedTeam,
                              items: teams
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedTeam = val;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                          ],

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText(
                                'الصلاحيات الممنوحة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: AppText(
                                  '${selectedPermissionIds.length} مختارة',
                                  style: const TextStyle(
                                    color: AppColorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColorScheme.surface),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: allPermissions.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.lock_open_rounded,
                                            size: 40,
                                            color: AppColorScheme.textMuted,
                                          ),
                                          SizedBox(height: 12),
                                          AppText(
                                            'لا توجد صلاحيات متاحة في النظام',
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: allPermissions.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final perm = allPermissions[index];
                                      final isSelected = selectedPermissionIds
                                          .contains(perm.id);
                                      return SwitchListTile(
                                        title: AppText(
                                          perm.displayName ?? perm.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: perm.category != null
                                            ? AppText(
                                                perm.category!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : null,
                                        value: isSelected,
                                        onChanged: (bool value) {
                                          setState(() {
                                            if (value) {
                                              selectedPermissionIds.add(
                                                perm.id,
                                              );
                                            } else {
                                              selectedPermissionIds.remove(
                                                perm.id,
                                              );
                                            }
                                          });
                                        },
                                        activeColor: AppColorScheme.primary,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const AppText(
                              'إلغاء',
                              style: TextStyle(color: AppColorScheme.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isEmpty) return;
                              if (selectedTeam == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('الرجاء اختيار الفريق'),
                                    backgroundColor: AppColorScheme.error,
                                  ),
                                );
                                return;
                              }

                              final data = {
                                'name': nameController.text,
                                'guard_name': 'web',
                                'team_id': selectedTeam?.id,
                                'permissions': selectedPermissionIds.toList(),
                              };

                              if (isEditing) {
                                context.read<SettingsCrudBloc>().add(
                                  UpdateRoleEvent(role.id, data),
                                );
                              } else {
                                context.read<SettingsCrudBloc>().add(
                                  CreateRoleEvent(data),
                                );
                              }
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: AppText(
                              isEditing ? 'حفظ التعديلات' : 'إنشاء الدور',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, RoleEntity role) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColorScheme.error),
            SizedBox(width: 8),
            AppText('حذف الدور'),
          ],
        ),
        content: AppText(
          'هل أنت متأكد من حذف دور "${role.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AppText('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCrudBloc>().add(DeleteRoleEvent(role.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const AppText('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
