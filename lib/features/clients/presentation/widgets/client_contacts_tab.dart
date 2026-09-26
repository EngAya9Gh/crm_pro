import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/client_contacts_cubit.dart';
import '../bloc/client_contacts_state.dart';
import '../../domain/entities/client_contact.dart';

class ClientContactsTab extends StatefulWidget {
  final String clientId;

  const ClientContactsTab({super.key, required this.clientId});

  @override
  State<ClientContactsTab> createState() => _ClientContactsTabState();
}

class _ClientContactsTabState extends State<ClientContactsTab> {
  late final ClientContactsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ClientContactsCubit>();
    _cubit.getContacts(widget.clientId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showAddEditDialog([ClientContact? contact]) {
    final isEditing = contact != null;
    final nameCtrl = TextEditingController(text: contact?.name ?? '');
    final phoneCtrl = TextEditingController(text: contact?.phone ?? '');
    final emailCtrl = TextEditingController(text: contact?.email ?? '');
    final positionCtrl = TextEditingController(text: contact?.position ?? '');
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: AppText(isEditing ? 'تعديل جهة اتصال' : 'إضافة جهة اتصال'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameCtrl,
                    hintText: 'الاسم',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneCtrl,
                    hintText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: emailCtrl,
                    hintText: 'البريد الإلكتروني (اختياري)',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: positionCtrl,
                    hintText: 'المنصب (اختياري)',
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const AppText('جهة اتصال أساسية'),
                    value: isPrimary,
                    onChanged: (val) {
                      setState(() {
                        isPrimary = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColorScheme.primary,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const AppText('إلغاء'),
              ),
              AppElevatedButton(
                text: isEditing ? 'تعديل' : 'إضافة',
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء إدخال الاسم ورقم الهاتف')),
                    );
                    return;
                  }

                  final data = {
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                    'position': positionCtrl.text.trim().isEmpty ? null : positionCtrl.text.trim(),
                    'is_primary': isPrimary,
                  };

                  if (isEditing) {
                    _cubit.updateContact(widget.clientId, contact.id, data);
                  } else {
                    _cubit.addContact(widget.clientId, data);
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(int contactId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف جهة اتصال'),
        content: const AppText('هل أنت متأكد من حذف جهة الاتصال هذه؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _cubit.deleteContact(widget.clientId, contactId);
              Navigator.pop(ctx);
            },
            child: const AppText(
              'حذف',
              style: TextStyle(color: AppColorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ClientContactsCubit, ClientContactsState>(
        listener: (context, state) {
          if (state is ClientContactsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.message)),
            );
          } else if (state is ClientContactsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ClientContactsInitial || state is ClientContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ClientContact> contacts = [];
          if (state is ClientContactsLoaded) {
            contacts = state.contacts;
          } else if (_cubit.state is ClientContactsLoaded) {
            contacts = (_cubit.state as ClientContactsLoaded).contacts;
          }

          return Stack(
            children: [
              if (contacts.isEmpty)
                const Center(
                  child: AppText(
                    'لا توجد جهات اتصال مضافة.',
                    style: TextStyle(color: AppColorScheme.textMuted),
                  ),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColorScheme.grey200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Row(
                          children: [
                            AppText(
                              contact.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (contact.isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const AppText(
                                  'الأساسي',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: AppColorScheme.textMuted),
                                const SizedBox(width: 6),
                                AppText(
                                  contact.phone,
                                  style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                            if (contact.email != null && contact.email!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: AppColorScheme.textMuted),
                                  const SizedBox(width: 6),
                                  AppText(
                                    contact.email!,
                                    style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                            if (contact.position != null && contact.position!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.work_outline, size: 14, color: AppColorScheme.textMuted),
                                  const SizedBox(width: 6),
                                  AppText(
                                    contact.position!,
                                    style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: AppColorScheme.grey600),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(contact);
                            } else if (value == 'delete') {
                              _confirmDelete(contact.id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('تعديل'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: AppColorScheme.error),
                                  SizedBox(width: 8),
                                  Text('حذف', style: TextStyle(color: AppColorScheme.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (state is ClientContactsOperationInProgress)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton(
                  backgroundColor: AppColorScheme.primary,
                  onPressed: () => _showAddEditDialog(),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
