import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/common/widgets/app_dropdown.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../evaluations/presentation/bloc/evaluation_types_cubit.dart';
import '../../../evaluations/presentation/bloc/evaluations_cubit.dart';
import '../../../evaluations/presentation/bloc/evaluations_state.dart';
import '../bloc/tickets_cubit.dart';
import '../bloc/tickets_state.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../data/models/ticket_model.dart';
import 'package:intl/intl.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isInternalNote = false;

  @override
  void initState() {
    super.initState();
    context.read<TicketsCubit>().getTicketDetails(widget.ticket);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<TicketsCubit>().addMessage(widget.ticket, text, _isInternalNote);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.ticket.ticketNumber,
      backgroundColor: AppColorScheme.background,
      actions: [
        if (widget.ticket.status != 'closed' && widget.ticket.status != 'resolved')
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: AppColorScheme.success),
            tooltip: 'إغلاق التذكرة',
            onPressed: () => _showCloseTicketDialog(context, widget.ticket),
          ),
      ],
      body: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          if (state is TicketsLoading) {
            return const Center(child: AppLoader());
          }

          Ticket currentTicket = widget.ticket;
          List<TicketMessage> messages = [];

          if (state is TicketDetailsLoaded && state.ticket.id == widget.ticket.id) {
            currentTicket = state.ticket;
            messages = state.messages;
          }

          return Column(
            children: [
              _buildTicketInfoCard(currentTicket),
              Expanded(
                child: _buildMessagesList(messages),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfoCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorScheme.grey200.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            ticket.title,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AppText(
            ticket.description ?? 'لا يوجد وصف',
            style: const TextStyle(color: AppColorScheme.textMuted),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColorScheme.textMuted),
                  const SizedBox(width: 4),
                  AppText(ticket.client?.name ?? 'غير معروف', style: const TextStyle(color: AppColorScheme.textMuted)),
                ],
              ),
              AppText(
                ticket.status,
                style: const TextStyle(color: AppColorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<TicketMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 60, color: AppColorScheme.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const AppText('لا توجد رسائل حتى الآن', style: TextStyle(color: AppColorScheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      reverse: true, // Newest at the bottom if we reverse the list
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Since we want newest at bottom, we need to adjust depending on API sorting.
        // Assuming API returns newest last. Let's not reverse yet.
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex]; 
        
        final isMe = message.user != null; // Simplification: assume if it has user it's agent, if null it's client.
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: message.isInternal 
                      ? Colors.orange.withOpacity(0.1) 
                      : (isMe ? AppColorScheme.primary.withOpacity(0.1) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: message.isInternal 
                        ? Colors.orange.withOpacity(0.3) 
                        : (isMe ? AppColorScheme.primary.withOpacity(0.2) : AppColorScheme.grey200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isInternal)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          AppText('ملاحظة داخلية', style: AppTypography.labelSmall.copyWith(color: Colors.orange)),
                        ],
                      ),
                    if (message.isInternal) const SizedBox(height: 4),
                    AppText(message.content),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    message.user?.name ?? 'العميل',
                    style: AppTypography.labelSmall.copyWith(color: AppColorScheme.textMuted, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    DateFormat('HH:mm - dd/MM/yyyy').format(message.createdAt),
                    style: AppTypography.labelSmall.copyWith(color: AppColorScheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _isInternalNote,
                onChanged: (val) => setState(() => _isInternalNote = val ?? false),
                activeColor: Colors.orange,
              ),
              const AppText('ملاحظة داخلية (لا يراها العميل)'),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _messageController,
                  hintText: 'اكتب ردك هنا...',
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCloseTicketDialog(BuildContext context, Ticket ticket) {
    int? selectedTypeId;
    int rating = 5;
    final noteController = TextEditingController();
    final ticketsCubit = context.read<TicketsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => getIt<EvaluationTypesCubit>()..getTypes(),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const AppText('إغلاق وتقييم التذكرة', style: TextStyle(fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppText('هل أنت متأكد من إغلاق التذكرة؟ يمكنك إضافة تقييم للعملية.'),
                      const SizedBox(height: 16),
                      BlocBuilder<EvaluationTypesCubit, EvaluationsState>(
                        builder: (context, typeState) {
                          if (typeState is EvaluationsLoading) {
                            return const Center(child: AppLoader());
                          }
                          final types = context.read<EvaluationTypesCubit>().types;
                          return AppDropdown<int?>(
                            label: 'نوع التقييم (اختياري)',
                            value: selectedTypeId,
                            items: [
                              const AppDropdownItem<int?>(value: null, label: 'بدون تقييم'),
                              ...types.map((t) => AppDropdownItem(value: t.id, label: t.name)),
                            ],
                            onChanged: (val) => setState(() => selectedTypeId = val),
                          );
                        },
                      ),
                      if (selectedTypeId != null) ...[
                        const SizedBox(height: 16),
                        const AppText('التقييم (عدد النجوم)'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 32,
                              ),
                              onPressed: () => setState(() => rating = index + 1),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: noteController,
                          label: 'ملاحظات العميل',
                          hintText: 'اكتب انطباع العميل...',
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const AppText('إلغاء', style: TextStyle(color: AppColorScheme.textMuted)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColorScheme.success),
                    onPressed: () {
                      final updatedTicket = TicketModel(
                        id: ticket.id,
                        ticketNumber: ticket.ticketNumber,
                        title: ticket.title,
                        description: ticket.description,
                        status: 'closed',
                        priority: ticket.priority,
                        source: ticket.source,
                        createdAt: ticket.createdAt,
                        clientIdStr: ticket.client?.id,
                        assignedToId: ticket.assignedTo?.id,
                        categoryId: ticket.category?.id,
                        evaluation: selectedTypeId != null ? {
                          'type_id': selectedTypeId,
                          'rating': rating,
                          'notes': noteController.text.trim(),
                        } : null,
                      );
                      ticketsCubit.updateTicket(ticket.id, updatedTicket);
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to list
                    },
                    child: const AppText('تأكيد الإغلاق', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
