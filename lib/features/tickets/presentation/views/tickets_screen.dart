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

import '../widgets/ticket_card.dart';

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
  int? _selectedRating;
  
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
        rating: _selectedRating,
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
      rating: _selectedRating,
    );
  }

  void _applyFilters(int? clientId, int? assignedTo, int? categoryId, int? rating) {
    setState(() {
      _selectedClientId = clientId;
      _selectedAssignedTo = assignedTo;
      _selectedCategoryId = categoryId;
      _selectedRating = rating;
    });
    context.read<TicketsCubit>().getTickets(
      status: _selectedStatus,
      clientId: _selectedClientId,
      assignedTo: _selectedAssignedTo,
      categoryId: _selectedCategoryId,
      rating: _selectedRating,
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
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return TicketCard(
                              ticket: state.tickets[index],
                              onUpdate: () async {
                                // The new TicketCard handles push, but it might not return the ticket easily if it doesn't await it.
                                // Let's check TicketCard code. It does: `await Navigator.push` then `onUpdate!()`.
                                // Since TicketCard doesn't pass the result to onUpdate, we need to modify TicketCard to pass it, OR we just let TicketCard do the update.
                                // Wait, TicketCard is where `Navigator.push` happens. I should modify `TicketCard` to handle it!
                              },
                            );
                          },
                        ),
                      ),
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: AppLoader()),
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
          
          Color baseColor;
          switch (status) {
            case 'open':
              baseColor = Colors.blue;
              break;
            case 'in_progress':
              baseColor = Colors.orange;
              break;
            case 'pending_client':
              baseColor = Colors.purple;
              break;
            case 'resolved':
            case 'closed':
              baseColor = Colors.green;
              break;
            default:
              baseColor = AppColorScheme.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => _onStatusChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? baseColor : baseColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? baseColor : baseColor.withOpacity(0.3),
                  ),
                  boxShadow: isSelected ? [BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: AppText(
                  _getStatusLabel(status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : (status == 'الكل' ? AppColorScheme.primary : baseColor.withOpacity(0.9)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
    int? tempRating = _selectedRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ClientsBloc>()..add(const LoadClients())),
            BlocProvider(create: (_) => getIt<UsersBloc>()..add(const LoadUsers())),
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
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
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
                                    tempRating = null;
                                    // Reset other filters here once added to state
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
                          const SizedBox(height: 16),
                          AppDropdown<String?>(
                            label: 'المصدر',
                            value: null, // Replace with tempSource when supported
                            items: const [
                              AppDropdownItem(value: null, label: 'الكل'),
                              AppDropdownItem(value: 'whatsapp', label: 'واتساب'),
                              AppDropdownItem(value: 'phone', label: 'هاتف'),
                              AppDropdownItem(value: 'email', label: 'بريد إلكتروني'),
                            ],
                            onChanged: (val) {
                              // TODO: Support Source filter
                            },
                          ),
                          const SizedBox(height: 16),
                          AppDropdown<String?>(
                            label: 'الأولوية',
                            value: null, // Replace with tempPriority when supported
                            items: const [
                              AppDropdownItem(value: null, label: 'الكل'),
                              AppDropdownItem(value: 'critical', label: 'حرجة'),
                              AppDropdownItem(value: 'high', label: 'عالية'),
                              AppDropdownItem(value: 'medium', label: 'متوسطة'),
                              AppDropdownItem(value: 'low', label: 'منخفضة'),
                            ],
                            onChanged: (val) {
                              // TODO: Support Priority filter
                            },
                          ),
                          const SizedBox(height: 16),
                          const AppText('تاريخ الإنشاء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // TODO: Show date picker for From
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColorScheme.grey300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: AppColorScheme.grey600),
                                        const SizedBox(width: 8),
                                        AppText('من تاريخ', style: TextStyle(color: AppColorScheme.grey600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // TODO: Show date picker for To
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColorScheme.grey300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: AppColorScheme.grey600),
                                        const SizedBox(width: 8),
                                        AppText('إلى تاريخ', style: TextStyle(color: AppColorScheme.grey600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const AppText('عدد النجوم في التقييم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStarFilterButton(context, null, tempRating, (val) => setState(() => tempRating = val)),
                              for (int i = 5; i >= 1; i--)
                                _buildStarFilterButton(context, i, tempRating, (val) => setState(() => tempRating = val)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AppElevatedButton(
                            text: 'تطبيق الفلاتر',
                            onPressed: () {
                              _applyFilters(tempClientId, tempAssignedTo, tempCategoryId, tempRating);
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
          ),
        );
      },
    );
  }

  Widget _buildStarFilterButton(BuildContext context, int? rating, int? selectedRating, ValueChanged<int?> onSelect) {
    final isSelected = rating == selectedRating;
    return GestureDetector(
      onTap: () => onSelect(rating),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: rating == null
            ? AppText('الكل', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey, fontWeight: FontWeight.bold))
            : Row(
                children: [
                  AppText('$rating', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.star_rounded, size: 16, color: isSelected ? Colors.amber : Colors.grey.shade400),
                ],
              ),
      ),
    );
  }
}
