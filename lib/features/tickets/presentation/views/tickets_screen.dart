import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_dropdown.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../clients/presentation/bloc/clients_bloc.dart';
import '../../../clients/presentation/bloc/clients_state.dart';
import '../../../clients/presentation/bloc/clients_event.dart';
import '../../../users/presentation/bloc/users_bloc.dart';
import '../../../users/presentation/bloc/users_event.dart';
import '../../../users/presentation/bloc/users_state.dart';
import '../bloc/ticket_categories_cubit.dart';
import '../bloc/tickets_cubit.dart';
import '../bloc/tickets_state.dart';
import '../../domain/entities/ticket.dart';
import 'create_ticket_screen.dart';
import 'ticket_details_screen.dart';
import 'package:intl/intl.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String? _selectedStatus;
  int? _selectedClientId;
  int? _selectedAssignedTo;
  int? _selectedCategoryId;
  
  final ScrollController _scrollController = ScrollController();
  
  final List<String> _statuses = [
    'الكل', 'open', 'in_progress', 'pending_client', 'resolved', 'closed'
  ];

  @override
  void initState() {
    super.initState();
    context.read<TicketsCubit>().getTickets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TicketsCubit>().loadNextPage(
        status: _selectedStatus,
        clientId: _selectedClientId,
        assignedTo: _selectedAssignedTo,
        categoryId: _selectedCategoryId,
      );
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status == 'الكل' ? null : status;
    });
    context.read<TicketsCubit>().getTickets(
      status: _selectedStatus,
      clientId: _selectedClientId,
      assignedTo: _selectedAssignedTo,
      categoryId: _selectedCategoryId,
    );
  }

  void _applyFilters(int? clientId, int? assignedTo, int? categoryId) {
    setState(() {
      _selectedClientId = clientId;
      _selectedAssignedTo = assignedTo;
      _selectedCategoryId = categoryId;
    });
    context.read<TicketsCubit>().getTickets(
      status: _selectedStatus,
      clientId: _selectedClientId,
      assignedTo: _selectedAssignedTo,
      categoryId: _selectedCategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إدارة التذاكر',
      backgroundColor: AppColorScheme.surface,
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: (_selectedClientId != null || _selectedAssignedTo != null || _selectedCategoryId != null) 
                ? AppColorScheme.primary 
                : AppColorScheme.textMuted,
          ),
          onPressed: _showFiltersBottomSheet,
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TicketsCubit>(),
              child: const CreateTicketScreen(),
            ),
          ));
        },
        backgroundColor: AppColorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText('تذكرة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<TicketsCubit, TicketsState>(
              builder: (context, state) {
                if (state is TicketsLoading) {
                  return const Center(child: AppLoader());
                } else if (state is TicketsError) {
                  return Center(
                    child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)),
                  );
                } else if (state is TicketsLoaded) {
                  if (state.tickets.isEmpty) return _buildEmptyState();
                  return Column(
                    children: [
                      if (state.meta != null) _buildMetaInfo(state.meta!.total, state.currentPage, state.meta!.lastPage),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.tickets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildTicketCard(state.tickets[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(int total, int current, int last) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColorScheme.surface,
      child: Row(
        children: [
          Icon(Icons.confirmation_num_outlined, size: 16, color: AppColorScheme.textMuted),
          const SizedBox(width: 6),
          AppText(
            '$total تذكرة - صفحة $current من $last',
            style: AppTypography.labelSmall.copyWith(color: AppColorScheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      color: AppColorScheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _statuses.length,
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final isSelected = (_selectedStatus == status) || (_selectedStatus == null && status == 'الكل');
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => _onStatusChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColorScheme.primary : AppColorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColorScheme.primary : AppColorScheme.grey200,
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: AppColorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: AppText(
                  _getStatusLabel(status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColorScheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: AppColorScheme.grey300),
          const SizedBox(height: 16),
          AppText('لا توجد تذاكر حالياً', style: AppTypography.titleLarge.copyWith(color: AppColorScheme.textMuted)),
          const SizedBox(height: 8),
          AppText('اضغط + لإنشاء تذكرة جديدة', style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppColorScheme.grey200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TicketsCubit>(),
                child: TicketDetailsScreen(ticket: ticket),
              ),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColorScheme.surface, borderRadius: BorderRadius.circular(8)),
                      child: AppText(ticket.ticketNumber, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _buildStatusBadge(ticket.status),
                  ],
                ),
                const SizedBox(height: 12),
                AppText(ticket.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: AppColorScheme.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText(ticket.client?.name ?? 'عميل غير معروف', style: const TextStyle(color: AppColorScheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    _buildPriorityBadge(ticket.priority),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColorScheme.textMuted),
                        const SizedBox(width: 4),
                        AppText(DateFormat('yyyy/MM/dd').format(ticket.createdAt), style: AppTypography.labelSmall),
                      ],
                    ),
                    if (ticket.category != null)
                      Row(
                        children: [
                          Icon(Icons.folder_open, size: 16, color: AppColorScheme.primary),
                          const SizedBox(width: 4),
                          AppText(ticket.category!.name, style: AppTypography.labelSmall.copyWith(color: AppColorScheme.primary)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor; Color textColor;
    switch (status) {
      case 'open': bgColor = Colors.blue.shade50; textColor = Colors.blue.shade700; break;
      case 'in_progress': bgColor = Colors.orange.shade50; textColor = Colors.orange.shade700; break;
      case 'pending_client': bgColor = Colors.purple.shade50; textColor = Colors.purple.shade700; break;
      case 'resolved': case 'closed': bgColor = Colors.green.shade50; textColor = Colors.green.shade700; break;
      default: bgColor = AppColorScheme.grey100; textColor = AppColorScheme.grey500;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: AppText(_getStatusLabel(status), style: AppTypography.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color iconColor;
    switch (priority) {
      case 'critical': iconColor = AppColorScheme.error; break;
      case 'high': iconColor = Colors.orange; break;
      case 'medium': iconColor = AppColorScheme.info; break;
      default: iconColor = AppColorScheme.success;
    }
    return Row(
      children: [
        Icon(Icons.local_fire_department, size: 14, color: iconColor),
        const SizedBox(width: 4),
        AppText(_getPriorityLabel(priority), style: AppTypography.labelSmall.copyWith(color: iconColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getStatusLabel(String status) {
    const map = {'الكل': 'الكل', 'open': 'مفتوحة', 'in_progress': 'قيد المعالجة', 'pending_client': 'بانتظار العميل', 'resolved': 'تم الحل', 'closed': 'مغلقة'};
    return map[status] ?? status;
  }

  String _getPriorityLabel(String priority) {
    const map = {'critical': 'حرجة', 'high': 'عالية', 'medium': 'متوسطة', 'low': 'منخفضة'};
    return map[priority] ?? priority;
  }

  void _showFiltersBottomSheet() {
    int? tempClientId = _selectedClientId;
    int? tempAssignedTo = _selectedAssignedTo;
    int? tempCategoryId = _selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ClientsBloc>()..add(LoadClients())),
            BlocProvider(create: (_) => getIt<UsersBloc>()..add(LoadUsers())),
            BlocProvider(create: (_) => getIt<TicketCategoriesCubit>()..getCategories()),
          ],
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppText(
                            'تصفية متقدمة',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                tempClientId = null;
                                tempAssignedTo = null;
                                tempCategoryId = null;
                              });
                            },
                            child: const AppText('إعادة ضبط', style: TextStyle(color: AppColorScheme.error)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<ClientsBloc, ClientsState>(
                        builder: (context, state) {
                          List<AppDropdownItem<int?>> items = [
                            const AppDropdownItem(value: null, label: 'الكل')
                          ];
                          if (state is ClientsLoaded) {
                            items.addAll(state.clients.map((c) => AppDropdownItem(value: int.tryParse(c.id), label: c.name)));
                          }
                          return AppDropdown<int?>(
                            label: 'العميل',
                            value: tempClientId,
                            items: items,
                            onChanged: (val) => setState(() => tempClientId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, state) {
                          List<AppDropdownItem<int?>> items = [
                            const AppDropdownItem(value: null, label: 'الكل')
                          ];
                          if (state.status == UsersStatus.success) {
                            items.addAll(state.users.map((u) => AppDropdownItem(value: u.id, label: u.name)));
                          }
                          return AppDropdown<int?>(
                            label: 'الموظف المسؤول',
                            value: tempAssignedTo,
                            items: items,
                            onChanged: (val) => setState(() => tempAssignedTo = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<TicketCategoriesCubit, TicketsState>(
                        builder: (context, state) {
                          List<AppDropdownItem<int?>> items = [
                            const AppDropdownItem(value: null, label: 'الكل')
                          ];
                          final categories = context.read<TicketCategoriesCubit>().categories;
                          items.addAll(categories.map((c) => AppDropdownItem(value: c.id, label: c.name)));
                          
                          return AppDropdown<int?>(
                            label: 'التصنيف',
                            value: tempCategoryId,
                            items: items,
                            onChanged: (val) => setState(() => tempCategoryId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      AppElevatedButton(
                        text: 'تطبيق الفلاتر',
                        onPressed: () {
                          _applyFilters(tempClientId, tempAssignedTo, tempCategoryId);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 24),
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
}
