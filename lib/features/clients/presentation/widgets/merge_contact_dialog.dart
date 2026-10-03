import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../../core/utils/end_points.dart';
import '../../data/models/client_model.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_contact.dart';
import '../bloc/client_contacts_cubit.dart';

class MergeContactDialog extends StatefulWidget {
  final ClientContact contact;
  final String sourceClientId;

  const MergeContactDialog({
    super.key,
    required this.contact,
    required this.sourceClientId,
  });

  @override
  State<MergeContactDialog> createState() => _MergeContactDialogState();
}

class _MergeContactDialogState extends State<MergeContactDialog> {
  Client? _selectedTargetClient;
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

  void _submit() {
    if (_selectedTargetClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('يرجى تحديد العميل الهدف', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    if (_selectedTargetClient!.id.toString() == widget.sourceClientId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('لا يمكن دمج جهة الاتصال مع نفس العميل', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    context.read<ClientContactsCubit>().mergeContact(widget.sourceClientId, _selectedTargetClient!.id.toString(), widget.contact.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('دمج جهة الاتصال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AppText('نقل جهة الاتصال (${widget.contact.name}) إلى عميل آخر', style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            const AppText('العميل الهدف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownSearch<Client>(
              items: (filter, _) => _searchClients(filter),
              compareFn: (i1, i2) => i1.id == i2.id,
              itemAsString: (Client c) => c.name,
              onSelected: (val) => setState(() => _selectedTargetClient = val),
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
                  hintText: 'اختر العميل الهدف...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
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
                    onPressed: _submit,
                    text: 'دمج',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
