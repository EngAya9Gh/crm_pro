import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../../domain/entities/lookup_entities.dart';
import '../bloc/lookups_bloc.dart';
import '../bloc/lookups_event.dart';
import '../bloc/lookups_state.dart';
import '../bloc/settings_crud_bloc.dart';
import '../bloc/settings_crud_event.dart';
import '../bloc/settings_crud_state.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LookupsBloc>()..add(LoadAllLookups())),
        BlocProvider(create: (_) => getIt<SettingsCrudBloc>()),
      ],
      child: const TeamsView(),
    );
  }
}

class TeamsView extends StatelessWidget {
  const TeamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إدارة الفرق',
      actions: [
        IconButton(
          onPressed: () => _showAddEditTeamDialog(context),
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
              final teams = state.lookups.teams;
              if (teams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_3_outlined,
                        size: 80,
                        color: AppColorScheme.textMuted.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const AppText(
                        'لا يوجد فرق مضافة',
                        style: TextStyle(color: AppColorScheme.textMuted),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return _buildTeamCard(context, team);
                },
              );
            }
            return const Center(child: AppText('حدث خطأ في تحميل البيانات'));
          },
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, TeamEntity team) {
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
          onTap: () => _showAddEditTeamDialog(context, team: team),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        team.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColorScheme.textMain,
                        ),
                      ),
                      if (team.description != null &&
                          team.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        AppText(
                          team.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColorScheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildActionButtons(context, team),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TeamEntity team) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showAddEditTeamDialog(context, team: team),
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
          onPressed: () => _confirmDelete(context, team),
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

  void _showAddEditTeamDialog(BuildContext context, {TeamEntity? team}) {
    final nameController = TextEditingController(text: team?.name ?? '');
    final descriptionController = TextEditingController(
      text: team?.description ?? '',
    );
    final isEditing = team != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.75, // Slightly shorter than roles
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
                        color: AppColorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.add_rounded,
                        color: AppColorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppText(
                      isEditing ? 'تعديل بيانات الفريق' : 'إضافة فريق جديد',
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
                        'المعلومات الأساسية',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: nameController,
                        hintText: 'اسم الفريق (مثال: المبيعات، التسويق)',
                        label: 'اسم الفريق',
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: descriptionController,
                        hintText: 'وصف مختصر لمهام الفريق',
                        label: 'الوصف (اختياري)',
                        maxLines: 3,
                      ),
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

                          final data = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                          };

                          if (isEditing) {
                            context.read<SettingsCrudBloc>().add(
                              UpdateTeamEvent(team.id, data),
                            );
                          } else {
                            context.read<SettingsCrudBloc>().add(
                              CreateTeamEvent(data),
                            );
                          }
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AppText(
                          isEditing ? 'حفظ التعديلات' : 'إضافة الفريق',
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
  }

  void _confirmDelete(BuildContext context, TeamEntity team) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColorScheme.error),
            SizedBox(width: 8),
            AppText('حذف الفريق'),
          ],
        ),
        content: AppText(
          'هل أنت متأكد من حذف فريق "${team.name}"؟ قد يؤثر ذلك على الموظفين المرتبطين به.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AppText('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCrudBloc>().add(DeleteTeamEvent(team.id));
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
