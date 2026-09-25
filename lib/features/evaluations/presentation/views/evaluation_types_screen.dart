import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_loader.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_elevated_button.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../../domain/entities/evaluation_type.dart';
import '../bloc/evaluation_types_cubit.dart';
import '../bloc/evaluations_state.dart';

class EvaluationTypesScreen extends StatelessWidget {
  const EvaluationTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EvaluationTypesCubit>()..getTypes(),
      child: AppScaffold(
        title: 'أنواع التقييمات',
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: AppColorScheme.primary,
              child: const Icon(Icons.add_rounded),
              onPressed: () => _showTypeDialog(context),
            );
          }
        ),
        body: BlocConsumer<EvaluationTypesCubit, EvaluationsState>(
          listener: (context, state) {
            if (state is EvaluationOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white))),
              );
            } else if (state is EvaluationsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColorScheme.error),
              );
            }
          },
          builder: (context, state) {
            if (state is EvaluationsLoading && context.read<EvaluationTypesCubit>().types.isEmpty) {
              return const Center(child: AppLoader());
            }

            final types = context.read<EvaluationTypesCubit>().types;

            if (types.isEmpty) {
              return const Center(child: AppText('لا يوجد أنواع تقييم حالياً'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<EvaluationTypesCubit>().getTypes();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: types.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final type = types[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColorScheme.grey200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: AppText(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: type.isActive ? AppColorScheme.success.withValues(alpha: 0.1) : AppColorScheme.grey200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AppText(
                              type.isActive ? 'نشط' : 'غير نشط',
                              style: TextStyle(
                                color: type.isActive ? AppColorScheme.success : AppColorScheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColorScheme.primary, size: 20),
                            onPressed: () => _showTypeDialog(context, type: type),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTypeDialog(BuildContext context, {EvaluationType? type}) {
    final isEditing = type != null;
    final nameController = TextEditingController(text: type?.name);
    bool isActive = type?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<EvaluationTypesCubit>(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isEditing ? 'تعديل النوع' : 'إضافة نوع تقييم جديد',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: nameController,
                      label: 'اسم النوع',
                      hintText: 'مثال: تقييم جودة الخدمة',
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const AppText('الحالة (نشط)'),
                      value: isActive,
                      activeColor: AppColorScheme.primary,
                      onChanged: (val) {
                        setState(() => isActive = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    AppElevatedButton(
                      text: 'حفظ',
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        
                        final newType = EvaluationType(
                          id: type?.id ?? 0,
                          name: nameController.text.trim(),
                          isActive: isActive,
                        );

                        if (isEditing) {
                          context.read<EvaluationTypesCubit>().updateType(newType.id, newType);
                        } else {
                          context.read<EvaluationTypesCubit>().createType(newType);
                        }

                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }
}
