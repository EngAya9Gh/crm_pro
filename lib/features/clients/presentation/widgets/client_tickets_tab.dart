import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../tickets/presentation/bloc/tickets_cubit.dart';
import '../../../tickets/presentation/bloc/tickets_state.dart';
import '../../../tickets/domain/entities/ticket.dart';
import '../../../tickets/presentation/widgets/ticket_card.dart';
import '../../../../core/common/widgets/app_dropdown.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';

class ClientTicketsTab extends StatefulWidget {
  final String clientId;
  
  const ClientTicketsTab({super.key, required this.clientId});

  @override
  State<ClientTicketsTab> createState() => _ClientTicketsTabState();
}

class _ClientTicketsTabState extends State<ClientTicketsTab> {
  late final TicketsCubit _ticketsCubit;
  final ScrollController _scrollController = ScrollController();

  String? _selectedStatus;
  final List<String> _statuses = [
    'الكل', 'open', 'in_progress', 'pending_client', 'resolved', 'closed'
  ];

  @override
  void initState() {
    super.initState();
    _ticketsCubit = getIt<TicketsCubit>();
    _ticketsCubit.getTickets(clientId: int.tryParse(widget.clientId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _ticketsCubit.loadNextPage(
        clientId: int.tryParse(widget.clientId),
        status: _selectedStatus,
      );
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status == 'الكل' ? null : status;
    });
    _ticketsCubit.getTickets(
      clientId: int.tryParse(widget.clientId),
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ticketsCubit,
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<TicketsCubit, TicketsState>(
              builder: (context, state) {
                if (state is TicketsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TicketsError) {
                  return Center(child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)));
                } else if (state is TicketsLoaded) {
                  if (state.tickets.isEmpty) {
                    return const Center(child: AppText('لا توجد تذاكر حالياً'));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.tickets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final ticket = state.tickets[index];
                            return TicketCard(
                              ticket: ticket,
                              onUpdate: () {
                                _ticketsCubit.getTickets(
                                  clientId: int.tryParse(widget.clientId),
                                  status: _selectedStatus,
                                  refresh: false,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
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

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statuses.length + 1, // +1 for filter icon
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: () {
                  _showFilterSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColorScheme.primary, size: 20),
                ),
              ),
            );
          }
          final status = _statuses[index - 1];
          final isSelected = (_selectedStatus == status) || (_selectedStatus == null && status == 'الكل');
          
          Color baseColor;
          switch (status) {
            case 'open': baseColor = Colors.blue; break;
            case 'in_progress': baseColor = Colors.orange; break;
            case 'pending_client': baseColor = Colors.purple; break;
            case 'resolved':
            case 'closed': baseColor = Colors.green; break;
            default: baseColor = AppColorScheme.primary;
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
                  border: Border.all(color: isSelected ? baseColor : baseColor.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: AppText(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
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

  String _getStatusLabel(String status) {
    const map = {'الكل': 'الكل', 'open': 'مفتوحة', 'in_progress': 'قيد المعالجة', 'pending_client': 'بانتظار العميل', 'resolved': 'تم الحل', 'closed': 'مغلقة'};
    return map[status] ?? status;
  }
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  const AppText('فلاتر متقدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // Date Range
                  const AppText('تاريخ التذكرة', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: AppTextField(hintText: 'من تاريخ', readOnly: true, prefixIcon: const Icon(Icons.date_range))),
                      const SizedBox(width: 10),
                      Expanded(child: AppTextField(hintText: 'إلى تاريخ', readOnly: true, prefixIcon: const Icon(Icons.date_range))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Priority
                  const AppText('الأهمية', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  AppDropdown<String>(
                    hint: 'اختر الأهمية',
                    showSearchBox: false,
                    legacyItems: const [
                      DropdownMenuItem(value: 'critical', child: Text('حرجة')),
                      DropdownMenuItem(value: 'high', child: Text('عالية')),
                      DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                      DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                    ],
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 20),
                  // Apply Button
                  AppElevatedButton(
                    text: 'تطبيق الفلاتر',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Apply filters
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
