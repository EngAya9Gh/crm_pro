import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../../core/utils/end_points.dart';
import '../../data/models/client_model.dart';
import '../../domain/entities/client.dart';
import '../bloc/global_contacts_cubit.dart';
import 'package:dio/dio.dart';

class AddGlobalContactDialog extends StatefulWidget {
  const AddGlobalContactDialog({super.key});

  @override
  State<AddGlobalContactDialog> createState() => _AddGlobalContactDialogState();
}

class _AddGlobalContactDialogState extends State<AddGlobalContactDialog> {
  Client? _selectedClient;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  bool _isPrimary = false;
  bool _isLoading = false;

  Future<List<Client>> _searchClients(String filter) async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.dio.get(EndPoints.clients, queryParameters: {
        'search': filter,
        'per_page': 20,
      });
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => ClientModel.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('data')) {
        return (data['data'] as List).map((e) => ClientModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error searching clients: $e');
    }
    return [];
  }

  void _submit() async {
    if (_selectedClient == null || _nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('يرجى تحديد العميل وإدخال الاسم ورقم الجوال', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiClient = getIt<ApiClient>();
      await apiClient.dio.post(
        '${EndPoints.clients}/${_selectedClient!.id}/contacts',
        data: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          'position': _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : null,
          'is_primary': _isPrimary ? 1 : 0,
        },
      );
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText('حدث خطأ: ${e.toString()}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText('إضافة جهة اتصال جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const AppText('تحديد العميل (مطلوب)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownSearch<Client>(
              items: (filter, _) => _searchClients(filter),
              compareFn: (i1, i2) => i1.id == i2.id,
              itemAsString: (Client c) => c.name,
              onSelected: (val) => setState(() => _selectedClient = val),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: const TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن عميل...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: 'اختر العميل...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'اسم جهة الاتصال',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phoneController,
                label: 'رقم الجوال',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني (اختياري)',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _positionController,
                label: 'المنصب (اختياري)',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isPrimary,
                    onChanged: (val) => setState(() => _isPrimary = val ?? false),
                    activeColor: AppColorScheme.primary,
                  ),
                  const AppText('تعيين كجهة اتصال أساسية للعميل'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      text: 'حفظ وإضافة',
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
