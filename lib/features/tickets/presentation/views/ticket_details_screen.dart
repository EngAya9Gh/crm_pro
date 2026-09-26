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
import 'create_ticket_screen.dart';
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

  Ticket? _latestTicket;

  @override
  void initState() {
    super.initState();
    _latestTicket = widget.ticket;
    context.read<TicketsCubit>().getTicketDetails(widget.ticket);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<TicketsCubit>().addMessage(_latestTicket ?? widget.ticket, text, _isInternalNote);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _latestTicket);
      },
      child: AppScaffold(
        title: widget.ticket.ticketNumber,
        backgroundColor: AppColorScheme.background,
        actions: [
          if (widget.ticket.status != 'closed')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColorScheme.primary),
              tooltip: 'تغيير حالة التذكرة',
              onSelected: (String newStatus) {
                if (newStatus == 'edit_ticket') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TicketsCubit>(),
                      child: CreateTicketScreen(ticket: _latestTicket ?? widget.ticket),
                    ),
                  ));
                } else if (newStatus == 'closed' || newStatus == 'resolved') {
                  _showCloseTicketDialog(context, _latestTicket ?? widget.ticket, newStatus);
                } else {
                  final ticketToUpdate = _latestTicket ?? widget.ticket;
                  final updatedTicket = TicketModel(
                    id: ticketToUpdate.id,
                    ticketNumber: ticketToUpdate.ticketNumber,
                    title: ticketToUpdate.title,
                    description: ticketToUpdate.description,
                    status: newStatus,
                    priority: ticketToUpdate.priority,
                    source: ticketToUpdate.source,
                    createdAt: ticketToUpdate.createdAt,
                    clientIdStr: ticketToUpdate.client?.id,
                    assignedToId: ticketToUpdate.assignedTo?.id,
                    categoryId: ticketToUpdate.category?.id,
                    evaluation: ticketToUpdate.evaluation,
                  );
                  context.read<TicketsCubit>().updateTicket(ticketToUpdate.id, updatedTicket);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit_ticket',
                  child: AppText('تعديل التذكرة', style: TextStyle(color: Colors.black)),
                ),
                const PopupMenuDivider(),
                if (widget.ticket.status != 'open')
                  const PopupMenuItem<String>(
                    value: 'open',
                    child: AppText('مفتوحة', style: TextStyle(color: Colors.blue)),
                  ),
                if (widget.ticket.status != 'in_progress')
                  const PopupMenuItem<String>(
                    value: 'in_progress',
                    child: AppText('قيد المعالجة', style: TextStyle(color: Colors.orange)),
                  ),
                if (widget.ticket.status != 'pending_client')
                  const PopupMenuItem<String>(
                    value: 'pending_client',
                    child: AppText('بانتظار العميل', style: TextStyle(color: Colors.purple)),
                  ),
                if (widget.ticket.status != 'resolved')
                  const PopupMenuItem<String>(
                    value: 'resolved',
                    child: AppText('تم الحل (إغلاق)', style: TextStyle(color: Colors.green)),
                  ),
                if (widget.ticket.status != 'closed')
                  const PopupMenuItem<String>(
                    value: 'closed',
                    child: AppText('مغلقة', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
        ],
        body: BlocBuilder<TicketsCubit, TicketsState>(
          builder: (context, state) {
            if (state is TicketsLoading) {
              return const Center(child: AppLoader());
            }

            Ticket currentTicket = _latestTicket ?? widget.ticket;
            List<TicketMessage> messages = [];

            if (state is TicketDetailsLoaded && state.ticket.id == widget.ticket.id) {
              currentTicket = state.ticket;
              messages = state.messages;
              // Using Future.microtask to avoid setState during build
              Future.microtask(() {
                if (mounted && _latestTicket != state.ticket) {
                  _latestTicket = state.ticket;
                }
              });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '#${ticket.ticketNumber}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColorScheme.primary),
              ),
              _buildStatusBadge(ticket.status),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            ticket.title,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (ticket.description != null && ticket.description!.isNotEmpty)
            AppText(
              ticket.description!,
              style: const TextStyle(color: AppColorScheme.textMuted),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColorScheme.grey200),
          ),
          _buildDetailRow(Icons.person_outline, 'العميل', ticket.client?.name ?? 'غير معروف'),
          _buildDetailRow(Icons.account_circle_outlined, 'الموظف المسؤول', ticket.assignedTo?.name ?? 'غير محدد'),
          _buildDetailRow(Icons.folder_open, 'التصنيف', ticket.category?.name ?? 'غير محدد'),
          if (ticket.subCategory != null)
            _buildDetailRow(Icons.account_tree_outlined, 'التصنيف الفرعي', ticket.subCategory!.name),
          _buildDetailRow(Icons.flag_outlined, 'الأولوية', _getPriorityLabel(ticket.priority)),
          _buildDetailRow(Icons.source_outlined, 'المصدر', ticket.source),
          _buildDetailRow(Icons.calendar_month_outlined, 'تاريخ الإنشاء', DateFormat('yyyy/MM/dd hh:mm a').format(ticket.createdAt)),
          
          if (ticket.evaluation != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColorScheme.grey200),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (ticket.evaluation!['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      ticket.evaluation!['notes'] ?? 'تم التقييم بنجاح',
                      style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColorScheme.textMuted),
          const SizedBox(width: 8),
          AppText('$label: ', style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13)),
          Expanded(
            child: AppText(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'open':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'in_progress':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'pending_client':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case 'resolved':
      case 'closed':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      default:
        bgColor = AppColorScheme.grey100;
        textColor = AppColorScheme.grey500;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: AppText(
        _getStatusLabel(status),
        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
      ),
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

  void _showCloseTicketDialog(BuildContext context, Ticket ticket, String status, {bool evaluateOnly = false}) {
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
                title: AppText(
                  evaluateOnly 
                      ? 'إضافة تقييم للتذكرة' 
                      : (status == 'resolved' ? 'حل التذكرة وتقييمها' : 'إغلاق وتقييم التذكرة'), 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        evaluateOnly 
                            ? 'أضف تقييماً لهذه التذكرة والخدمة المقدمة بها.'
                            : (status == 'resolved' 
                                ? 'هل أنت متأكد من تغيير حالة التذكرة إلى تم الحل؟ يمكنك إضافة تقييم للعملية.' 
                                : 'هل أنت متأكد من إغلاق التذكرة نهائياً؟ يمكنك إضافة تقييم للعملية.')
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<EvaluationTypesCubit, EvaluationsState>(
                        builder: (context, typeState) {
                          if (typeState is EvaluationsLoading) {
                            return const Center(child: AppLoader());
                          }
                          final types = context.read<EvaluationTypesCubit>().types;
                          return AppDropdown<int?>(
                            label: evaluateOnly ? 'نوع التقييم' : 'نوع التقييم (اختياري)',
                            value: selectedTypeId,
                            items: [
                              if (!evaluateOnly) const AppDropdownItem<int?>(value: null, label: 'بدون تقييم'),
                              ...types.map((t) => AppDropdownItem(value: t.id, label: t.name)),
                            ],
                            onChanged: (val) => setState(() => selectedTypeId = val),
                          );
                        },
                      ),
                      if (selectedTypeId != null || evaluateOnly) ...[
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
                      if (evaluateOnly && selectedTypeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار نوع التقييم', style: TextStyle(color: Colors.white))));
                        return;
                      }
                      
                      final updatedTicket = TicketModel(
                        id: ticket.id,
                        ticketNumber: ticket.ticketNumber,
                        title: ticket.title,
                        description: ticket.description,
                        status: status, // status remains the same if evaluateOnly
                        priority: ticket.priority,
                        source: ticket.source,
                        createdAt: ticket.createdAt,
                        clientIdStr: ticket.client?.id,
                        assignedToId: ticket.assignedTo?.id,
                        categoryId: ticket.category?.id,
                        evaluation: (selectedTypeId != null) ? {
                          'type_id': selectedTypeId,
                          'rating': rating,
                          'notes': noteController.text.trim(),
                        } : ticket.evaluation,
                      );
                      ticketsCubit.updateTicket(ticket.id, updatedTicket);
                      Navigator.pop(context); // Close dialog
                      if (!evaluateOnly) Navigator.pop(context); // Go back to list if closing ticket
                    },
                    child: AppText(evaluateOnly ? 'حفظ التقييم' : 'تأكيد الإغلاق', style: const TextStyle(color: Colors.white)),
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
