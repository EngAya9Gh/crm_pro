import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_bloc.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_state.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_event.dart';
import 'package:crm_wakeel/core/common/widgets/app_drawer.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import '../widgets/invoice_card.dart';
import 'add_edit_invoice_screen.dart';
import 'invoice_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late final InvoicesBloc _invoicesBloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;
  List<int>? _selectedTagIds;
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _invoicesBloc = getIt<InvoicesBloc>()..add(const LoadInvoices());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _invoicesBloc.close();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _invoicesBloc.add(LoadMoreInvoices());
    }
  }

  void _onSearch(String query) {
    _invoicesBloc.add(
      LoadInvoices(
        search: query.isEmpty ? null : query,
        status: _selectedStatus,
        tagIds: _selectedTagIds,
        userId: _selectedUserId,
        isRefresh: true,
      ),
    );
  }

  void _onFilterByStatus(String? status) {
    setState(() => _selectedStatus = status);
    _invoicesBloc.add(
      LoadInvoices(
        status: status,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        tagIds: _selectedTagIds,
        userId: _selectedUserId,
        isRefresh: true,
      ),
    );
  }

  void _onFilterByTags(List<int>? tagIds) {
    setState(() => _selectedTagIds = tagIds);
    _invoicesBloc.add(
      LoadInvoices(
        status: _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        tagIds: tagIds,
        userId: _selectedUserId,
        isRefresh: true,
      ),
    );
  }

  void _showFiltersBottomSheet() {
    String? tempSelectedStatus = _selectedStatus;
    List<int> tempSelectedTags = List.from(_selectedTagIds ?? []);
    int? tempSelectedUserId = _selectedUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<LookupsBloc>(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText(
                            'تصفية الفواتير',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AppText(
                        'حالة الفاتورة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [null, 'paid', 'pending', 'overdue', 'draft']
                            .map((status) {
                              return ChoiceChip(
                                label: AppText(
                                  status == null
                                      ? 'الكل'
                                      : _getStatusLabel(status),
                                  style: TextStyle(
                                    color: tempSelectedStatus == status
                                        ? AppColorScheme.white
                                        : _getStatusColor(status),
                                  ),
                                ),
                                selected: tempSelectedStatus == status,
                                selectedColor: _getStatusColor(status),
                                checkmarkColor: AppColorScheme.white,
                                backgroundColor: _getStatusColor(
                                  status,
                                ).withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: _getStatusColor(
                                      status,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                onSelected: (selected) {
                                  setState(() => tempSelectedStatus = status);
                                },
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      const AppText(
                        'الوسوم',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<LookupsBloc, LookupsState>(
                        builder: (context, state) {
                          if (state is LookupsLoading ||
                              state is LookupsInitial) {
                            if (state is LookupsInitial) {
                              context.read<LookupsBloc>().add(LoadAllLookups());
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (state is LookupsLoaded) {
                            final allTags = state.lookups.invoiceTags;
                            if (allTags.isEmpty) {
                              return const AppText('لا توجد وسوم متاحة');
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allTags.map((tag) {
                                final isSelected = tempSelectedTags.contains(
                                  tag.id,
                                );
                                return FilterChip(
                                  label: AppText(
                                    tag.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColorScheme.white
                                          : _parseColor(
                                              tag.color,
                                              fallbackName: tag.name,
                                            ),
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: _parseColor(
                                    tag.color,
                                    fallbackName: tag.name,
                                  ),
                                  checkmarkColor: AppColorScheme.white,
                                  backgroundColor: _parseColor(
                                    tag.color,
                                    fallbackName: tag.name,
                                  ).withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: _parseColor(
                                        tag.color,
                                        fallbackName: tag.name,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        tempSelectedTags.add(tag.id);
                                      } else {
                                        tempSelectedTags.remove(tag.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          }
                          return const AppText('حدث خطأ أثناء تحميل الوسوم');
                        },
                      ),
                      const SizedBox(height: 24),
                      const AppText(
                        'الموظف المسؤول',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<LookupsBloc, LookupsState>(
                        builder: (context, state) {
                          if (state is LookupsLoaded) {
                            return DropdownButtonFormField<int>(
                              value: tempSelectedUserId,
                              decoration: const InputDecoration(
                                hintText: 'اختر الموظف',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: AppText('الكل'),
                                ),
                                ...state.employees.map((emp) {
                                  return DropdownMenuItem<int>(
                                    value: emp.id,
                                    child: AppText(emp.name),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  tempSelectedUserId = val;
                                });
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  tempSelectedStatus = null;
                                  tempSelectedTags.clear();
                                  tempSelectedUserId = null;
                                });
                              },
                              child: const AppText('مسح الفلاتر'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                this.setState(() {
                                  _selectedStatus = tempSelectedStatus;
                                  _selectedTagIds = tempSelectedTags.isEmpty
                                      ? null
                                      : tempSelectedTags;
                                  _selectedUserId = tempSelectedUserId;
                                });
                                _invoicesBloc.add(
                                  LoadInvoices(
                                    status: _selectedStatus,
                                    search: _searchController.text.isEmpty
                                        ? null
                                        : _searchController.text,
                                    tagIds: _selectedTagIds,
                                    userId: _selectedUserId,
                                    isRefresh: true,
                                  ),
                                );
                              },
                              child: const AppText('تطبيق'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _invoicesBloc,
      child: AppScaffold(
        title: 'الفواتير',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColorScheme.textMain),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _invoicesBloc,
                    child: const AddEditInvoiceScreen(),
                  ),
                ),
              );
            },
          ),
        ],
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _searchController,
                          hintText: 'بحث عن فاتورة...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColorScheme.textMuted,
                          ),
                          onChanged: (value) {
                            // Debounce search
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (_searchController.text == value) {
                                  _onSearch(value);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColorScheme.secondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppColorScheme.secondary,
                          ),
                          onPressed: _showFiltersBottomSheet,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedStatus != null ||
                      (_selectedTagIds != null &&
                          _selectedTagIds!.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (_selectedStatus != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: AppText(
                                  'الحالة: ${_getStatusLabel(_selectedStatus!)}',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _onFilterByStatus(null),
                                backgroundColor: AppColorScheme.primary
                                    .withValues(alpha: 0.1),
                                side: BorderSide.none,
                              ),
                            ),
                          if (_selectedTagIds != null &&
                              _selectedTagIds!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: AppText(
                                  'الوسوم (${_selectedTagIds!.length})',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _onFilterByTags(null),
                                backgroundColor: AppColorScheme.primary
                                    .withValues(alpha: 0.1),
                                side: BorderSide.none,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            BlocBuilder<InvoicesBloc, InvoicesState>(
              builder: (context, state) {
                if (state.status == InvoicesStatus.initial ||
                    state.total == 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      AppText(
                        'الصفحة ${state.page} من ${state.lastPage}',
                        style: const TextStyle(
                          color: AppColorScheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      AppText(
                        'إجمالي الفواتير: ${state.total}',
                        style: const TextStyle(
                          color: AppColorScheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Invoices List
            Expanded(
              child: BlocConsumer<InvoicesBloc, InvoicesState>(
                listener: (context, state) {
                  if (state.operationStatus == InvoiceOperationStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: AppText(state.operationMessage)),
                    );
                  } else if (state.operationStatus ==
                      InvoiceOperationStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AppText(state.operationMessage),
                        backgroundColor: AppColorScheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == InvoicesStatus.loading &&
                      state.invoices.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == InvoicesStatus.failure &&
                      state.invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          AppText(
                            state.errorMessage,
                            style: const TextStyle(color: AppColorScheme.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _invoicesBloc.add(const LoadInvoices()),
                            child: const AppText('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppColorScheme.textMuted.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const AppText(
                            'لا توجد فواتير',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColorScheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _invoicesBloc.add(
                        LoadInvoices(
                          status: _selectedStatus,
                          search: _searchController.text.isEmpty
                              ? null
                              : _searchController.text,
                          isRefresh: true,
                        ),
                      );
                    },
                    child: AppListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.hasReachedMax
                          ? state.invoices.length
                          : state.invoices.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.invoices.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final invoice = state.invoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: _invoicesBloc,
                                  child: InvoiceDetailsScreen(
                                    invoiceId: invoice.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _invoicesBloc,
                  child: const AddEditInvoiceScreen(),
                ),
              ),
            );
          },
          backgroundColor: AppColorScheme.primary,
          child: const Icon(Icons.add, color: AppColorScheme.white),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'مدفوعة';
      case 'pending':
        return 'معلقة';
      case 'overdue':
        return 'متأخرة';
      case 'draft':
        return 'مسودة';
      default:
        return status;
    }
  }

  Color _parseColor(String hexColor, {String? fallbackName}) {
    if (hexColor == '#000000' && fallbackName != null) {
      final hash = fallbackName.hashCode;
      final hue = (hash % 360).toDouble();
      return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
    }
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppColorScheme.primary;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return AppColorScheme.success;
      case 'overdue':
        return AppColorScheme.error;
      case 'sent':
      case 'pending':
        return AppColorScheme.info;
      case 'cancelled':
        return AppColorScheme.textMuted;
      case 'draft':
      default:
        return AppColorScheme.primary;
    }
  }
}
