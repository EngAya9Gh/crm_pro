import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../tickets/presentation/bloc/tickets_cubit.dart';
import '../../../tickets/presentation/bloc/tickets_state.dart';
import '../../../tickets/domain/entities/ticket.dart';
import '../../../tickets/presentation/views/ticket_details_screen.dart';
import 'package:intl/intl.dart';

class ClientTicketsTab extends StatefulWidget {
  final String clientId;
  
  const ClientTicketsTab({super.key, required this.clientId});

  @override
  State<ClientTicketsTab> createState() => _ClientTicketsTabState();
}

class _ClientTicketsTabState extends State<ClientTicketsTab> {
  late final TicketsCubit _ticketsCubit;

  @override
  void initState() {
    super.initState();
    _ticketsCubit = getIt<TicketsCubit>();
    _ticketsCubit.getTickets(clientId: int.tryParse(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ticketsCubit,
      child: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          if (state is TicketsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TicketsError) {
            return Center(child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)));
          } else if (state is TicketsLoaded) {
            if (state.tickets.isEmpty) {
              return const Center(child: AppText('لا توجد تذاكر لهذا العميل'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return _buildTicketCard(ticket);
              },
            );
          }
          return const SizedBox.shrink();
        },
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
                value: _ticketsCubit,
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
                      child: AppText(ticket.ticketNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    _buildStatusBadge(ticket.status),
                  ],
                ),
                const SizedBox(height: 12),
                AppText(ticket.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriorityBadge(ticket.priority),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColorScheme.textMuted),
                        const SizedBox(width: 4),
                        AppText(DateFormat('yyyy/MM/dd').format(ticket.createdAt), style: const TextStyle(fontSize: 12, color: AppColorScheme.textMuted)),
                      ],
                    ),
                    if (ticket.category != null)
                      Row(
                        children: [
                          const Icon(Icons.folder_open, size: 16, color: AppColorScheme.primary),
                          const SizedBox(width: 4),
                          AppText(ticket.category!.name, style: const TextStyle(fontSize: 12, color: AppColorScheme.primary)),
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
      child: AppText(_getStatusLabel(status), style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
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
        AppText(_getPriorityLabel(priority), style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getStatusLabel(String status) {
    const map = {'open': 'مفتوحة', 'in_progress': 'قيد المعالجة', 'pending_client': 'بانتظار العميل', 'resolved': 'تم الحل', 'closed': 'مغلقة'};
    return map[status] ?? status;
  }

  String _getPriorityLabel(String priority) {
    const map = {'critical': 'حرجة', 'high': 'عالية', 'medium': 'متوسطة', 'low': 'منخفضة'};
    return map[priority] ?? priority;
  }
}
