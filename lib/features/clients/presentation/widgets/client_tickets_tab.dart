import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../tickets/presentation/bloc/tickets_cubit.dart';
import '../../../tickets/presentation/bloc/tickets_state.dart';
import '../../../tickets/domain/entities/ticket.dart';

class ClientTicketsTab extends StatefulWidget {
  final int clientId;
  
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
    _ticketsCubit.getTickets(clientId: widget.clientId);
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
    return Card(
      color: AppColorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColorScheme.border),
      ),
      child: ListTile(
        title: AppText(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: AppText('رقم: ${ticket.ticketNumber} - حالة: ${ticket.status}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to ticket details
        },
      ),
    );
  }
}
