import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        isRefresh: true,
      ),
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
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppColorScheme.secondary,
                          ),
                          onSelected: _onFilterByStatus,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: null,
                              child: AppText('الكل'),
                            ),
                            const PopupMenuItem(
                              value: 'paid',
                              child: AppText('مدفوعة'),
                            ),
                            const PopupMenuItem(
                              value: 'pending',
                              child: AppText('معلقة'),
                            ),
                            const PopupMenuItem(
                              value: 'overdue',
                              child: AppText('متأخرة'),
                            ),
                            const PopupMenuItem(
                              value: 'draft',
                              child: AppText('مسودة'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_selectedStatus != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: AppText(_getStatusLabel(_selectedStatus!)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _onFilterByStatus(null),
                          backgroundColor: AppColorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

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
}
