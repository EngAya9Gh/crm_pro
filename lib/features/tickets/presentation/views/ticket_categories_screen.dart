import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_loader.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_dropdown.dart';
import 'package:crm_wakeel/core/common/widgets/app_elevated_button.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../../domain/entities/ticket_category.dart';
import '../bloc/ticket_categories_cubit.dart';
import '../bloc/tickets_state.dart';

class TicketCategoriesScreen extends StatelessWidget {
  const TicketCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TicketCategoriesCubit>()..getCategories(),
      child: AppScaffold(
        title: 'تصنيفات التذاكر',
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: AppColorScheme.primary,
              child: const Icon(Icons.add_rounded),
              onPressed: () => _showCategoryDialog(context),
            );
          }
        ),
        body: BlocConsumer<TicketCategoriesCubit, TicketsState>(
          listener: (context, state) {
            if (state is TicketOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white))),
              );
            } else if (state is TicketsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColorScheme.error),
              );
            }
          },
          builder: (context, state) {
            if (state is TicketsLoading && context.read<TicketCategoriesCubit>().categories.isEmpty) {
              return const Center(child: AppLoader());
            }

            final categories = context.read<TicketCategoriesCubit>().categories;

            if (categories.isEmpty) {
              return const Center(child: AppText('لا يوجد تصنيفات حالياً'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<TicketCategoriesCubit>().getCategories();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColorScheme.grey200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: AppText(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: AppText('SLA: ${category.slaHours ?? 0} ساعة', style: const TextStyle(color: AppColorScheme.textMuted)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: category.isActive ? AppColorScheme.success.withValues(alpha: 0.1) : AppColorScheme.grey200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AppText(
                              category.isActive ? 'نشط' : 'غير نشط',
                              style: TextStyle(
                                color: category.isActive ? AppColorScheme.success : AppColorScheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColorScheme.primary, size: 20),
                            onPressed: () => _showCategoryDialog(context, category: category),
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

  void _showCategoryDialog(BuildContext context, {TicketCategory? category, int? parentId}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name);
    final slaController = TextEditingController(text: category?.slaHours?.toString() ?? '24');
    bool isActive = category?.isActive ?? true;
    
    // We get the list of top-level categories to be used as potential parents
    final categories = context.read<TicketCategoriesCubit>().categories;
    // Filter out the current category so it can't be its own parent
    final potentialParents = categories.where((c) => c.id != category?.id).toList();
    
    int? selectedParentId = isEditing ? category?.parentId : parentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<TicketCategoriesCubit>(),
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
                      isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (potentialParents.isNotEmpty) ...[
                      AppDropdown<int?>(
                        label: 'التصنيف الأب (اختياري)',
                        value: selectedParentId,
                        items: [
                          const AppDropdownItem(value: null, label: 'تصنيف رئيسي (بدون أب)'),
                          ...potentialParents.map((c) => AppDropdownItem(value: c.id, label: c.name)),
                        ],
                        onChanged: (val) => setState(() => selectedParentId = val),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      controller: nameController,
                      label: 'اسم التصنيف',
                      hintText: 'مثال: شكوى فنية',
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: slaController,
                      label: 'وقت الاستجابة SLA (بالساعات)',
                      hintText: 'مثال: 24',
                      keyboardType: TextInputType.number,
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
                        
                        final newCategory = TicketCategory(
                          id: category?.id ?? 0,
                          name: nameController.text.trim(),
                          slaHours: int.tryParse(slaController.text.trim()) ?? 24,
                          isActive: isActive,
                          parentId: selectedParentId,
                        );

                        if (isEditing) {
                          context.read<TicketCategoriesCubit>().updateCategory(newCategory.id, newCategory);
                        } else {
                          context.read<TicketCategoriesCubit>().createCategory(newCategory);
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
