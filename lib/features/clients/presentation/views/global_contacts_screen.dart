import 'package:flutter/material.dart';
import '../widgets/add_global_contact_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_drawer.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/global_contacts_cubit.dart';
import '../../domain/entities/client_contact.dart';

class GlobalContactsScreen extends StatefulWidget {
  const GlobalContactsScreen({super.key});

  @override
  State<GlobalContactsScreen> createState() => _GlobalContactsScreenState();
}

class _GlobalContactsScreenState extends State<GlobalContactsScreen> {
  late final GlobalContactsCubit _cubit;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _cubit = getIt<GlobalContactsCubit>();
    _cubit.fetchContacts(isRefresh: true);

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _cubit.fetchContacts();
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _applyFilter(String key, dynamic value) {
    if (value == null || value == '') {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }
    _cubit.fetchContacts(filters: _filters, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const AppText('دليل جهات الاتصال')),
        drawer: const AppDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final added = await showDialog<bool>(
              context: context,
              builder: (_) => const AddGlobalContactDialog(),
            );
            if (added == true && context.mounted) {
              _cubit.fetchContacts(isRefresh: true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const AppText(
                    'تم إضافة جهة الاتصال بنجاح',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColorScheme.success,
                ),
              );
            }
          },
          backgroundColor: AppColorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: BlocBuilder<GlobalContactsCubit, GlobalContactsState>(
                builder: (context, state) {
                  if (state is GlobalContactsInitial ||
                      (state is GlobalContactsLoading &&
                          _cubit.state is! GlobalContactsLoaded)) {
                    return const Center(child: AppLoader());
                  } else if (state is GlobalContactsError) {
                    return Center(
                      child: AppText(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is GlobalContactsLoaded) {
                    final contacts = state.contacts;
                    if (contacts.isEmpty) {
                      return const Center(
                        child: AppText('لا توجد جهات اتصال توافق بحثك.'),
                      );
                    }
                    return ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          contacts.length + (state.hasReachedMax ? 0 : 1),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == contacts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: AppLoader(),
                            ),
                          );
                        }
                        return _buildContactCard(contacts[index]);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _searchCtrl,
                  hintText: 'ابحث بالاسم، الرقم، أو البريد...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (val) {
                    _applyFilter('search', val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Toggle is_primary
              FilterChip(
                label: const AppText('أساسية فقط'),
                selected: _filters['is_primary'] == 'true',
                onSelected: (val) {
                  _applyFilter('is_primary', val ? 'true' : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Position filter (Could be a dropdown, simplified here as a text field for custom search)
          AppTextField(
            hintText: 'تصفية حسب المنصب (مثال: مدير، محاسب)',
            onChanged: (val) {
              _applyFilter('position', val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ClientContact contact) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: AppText(
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '؟',
                    style: const TextStyle(color: AppColorScheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (contact.position != null &&
                          contact.position!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorScheme.grey200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            contact.position!,
                            style: const TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (contact.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const AppText(
                      'أساسي',
                      style: TextStyle(
                        color: AppColorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColorScheme.textMuted,
                ),
                const SizedBox(width: 8),
                AppText(contact.phone),
              ],
            ),
            if (contact.email != null && contact.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email,
                    size: 16,
                    color: AppColorScheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  AppText(contact.email!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
