import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/tickets_cubit.dart';
import '../../domain/entities/ticket.dart';
import '../views/ticket_details_screen.dart';
import '../../../users/presentation/bloc/users_bloc.dart' as crm_users;
import '../../../users/presentation/bloc/users_state.dart' as crm_users;
import '../../../users/presentation/bloc/users_event.dart' as crm_users;
import '../../data/models/ticket_model.dart' as crm_ticket_model;
import '../bloc/ticket_categories_cubit.dart';
import '../bloc/tickets_state.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onUpdate;

  const TicketCard({super.key, required this.ticket, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorScheme.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColorScheme.grey200.withOpacity(0.8), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final cubit = context.read<TicketsCubit>();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<TicketsCubit>(),
                  child: TicketDetailsScreen(ticket: ticket),
                ),
              ),
            );
            if (result != null && result is Ticket) {
              cubit.updateTicketLocally(result);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ticket Number, Status Badge, 3-dot menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        '#${ticket.ticketNumber}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildPriorityBadge(ticket.priority),
                    const SizedBox(width: 8),
                    _buildStatusBadge(context, ticket.status),
                    const SizedBox(width: 4),
                    // ── 3-dot quick actions menu ──
                    _buildActionsMenu(context),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                AppText(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: AppColorScheme.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description
                if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                  AppText(
                    ticket.description!,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColorScheme.textMuted.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                ],

                // Chips row: category · subcategory · source · assignee
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildChip(
                      Icons.folder_open,
                      ticket.category?.name ?? 'بدون تصنيف',
                      AppColorScheme.primary,
                    ),
                    if (ticket.subCategory != null)
                      _buildChip(
                        Icons.account_tree_outlined,
                        ticket.subCategory!.name,
                        Colors.teal,
                      ),
                    _buildSourceBadge(ticket.source),
                    if (ticket.assignedTo != null)
                      _buildChip(
                        Icons.person_outline,
                        ticket.assignedTo!.name,
                        AppColorScheme.grey600,
                      ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColorScheme.grey200),
                ),

                // Footer: Date
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        size: 14, color: AppColorScheme.textMuted.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    AppText(
                      DateFormat('yyyy/MM/dd hh:mm a').format(ticket.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorScheme.textMuted.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Last Message
                if (ticket.lastMessage != null && ticket.lastMessage!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorScheme.grey50.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColorScheme.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.forum_outlined,
                              size: 14, color: AppColorScheme.textMuted),
                          const SizedBox(width: 6),
                          AppText('آخر رسالة',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColorScheme.textMuted,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 4),
                        AppText(
                          ticket.lastMessage!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColorScheme.textMain, height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],

                // Evaluation
                if (ticket.evaluation != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
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
                              index < (ticket.evaluation!['rating'] ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            ticket.evaluation!['notes'] ?? 'تم التقييم',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 3-dot menu ──────────────────────────────────────────────────────────────
  Widget _buildActionsMenu(BuildContext context) {
    // Capture cubit BEFORE showing menu (still in the widget tree context)
    final ticketsCubit = context.read<TicketsCubit>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: AppColorScheme.grey600),
      tooltip: 'إجراءات سريعة',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'assign':
            _showAssignSheet(context, ticketsCubit);
            break;
          case 'category':
            _showCategorySheet(context, ticketsCubit, isSubCategory: false);
            break;
          case 'sub_category':
            if (ticket.category == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('الرجاء اختيار التصنيف الرئيسي أولاً'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              _showCategorySheet(context, ticketsCubit,
                  isSubCategory: true, parentId: ticket.category!.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'assign',
          child: Row(
            children: [
              Icon(Icons.person_add_outlined, size: 18, color: AppColorScheme.primary),
              SizedBox(width: 10),
              Text('إسناد الموظف'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'category',
          child: Row(
            children: [
              Icon(Icons.folder_open_outlined, size: 18, color: AppColorScheme.primary),
              SizedBox(width: 10),
              Text('التصنيف الرئيسي'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'sub_category',
          child: Row(
            children: [
              Icon(Icons.account_tree_outlined, size: 18, color: Colors.teal),
              SizedBox(width: 10),
              Text('التصنيف الفرعي'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Status badge (popup) ─────────────────────────────────────────────────────
  Widget _buildStatusBadge(BuildContext context, String status) {
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

    final ticketsCubit = context.read<TicketsCubit>();

    return PopupMenuButton<String>(
      tooltip: 'تغيير الحالة',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (newStatus) {
        if (newStatus == status) return;
        _doUpdate(ticketsCubit, status: newStatus);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'open', child: Text('مفتوحة')),
        const PopupMenuItem(value: 'in_progress', child: Text('قيد المعالجة')),
        const PopupMenuItem(value: 'pending_client', child: Text('بانتظار العميل')),
        const PopupMenuItem(value: 'resolved', child: Text('تم الحل')),
        const PopupMenuItem(value: 'closed', child: Text('مغلقة')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              _getStatusLabel(status),
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: textColor),
          ],
        ),
      ),
    );
  }

  // ── Assign bottom sheet ──────────────────────────────────────────────────────
  void _showAssignSheet(BuildContext context, TicketsCubit ticketsCubit) {
    final usersBloc = getIt<crm_users.UsersBloc>();
    if (usersBloc.state.users.isEmpty &&
        usersBloc.state.status != crm_users.UsersStatus.loading) {
      usersBloc.add(crm_users.LoadUsers());
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: AppText('إسناد التذكرة إلى',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              BlocBuilder<crm_users.UsersBloc, crm_users.UsersState>(
                bloc: usersBloc,
                builder: (_, state) {
                  if (state.status == crm_users.UsersStatus.loading) {
                    return const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator());
                  }
                  if (state.users.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.all(20),
                        child: AppText('لا يوجد موظفين متاحين'));
                  }
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.users.length,
                      itemBuilder: (_, index) {
                        final user = state.users[index];
                        final isSelected = ticket.assignedTo?.id == user.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColorScheme.primary
                                : AppColorScheme.grey200,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0] : '؟',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColorScheme.textMain,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: AppText(user.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColorScheme.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _doUpdate(ticketsCubit, assignedTo: user);
                            _showSuccessSnack(context, 'تم إسناد التذكرة إلى ${user.name}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Category bottom sheet ────────────────────────────────────────────────────
  void _showCategorySheet(
    BuildContext context,
    TicketsCubit ticketsCubit, {
    required bool isSubCategory,
    int? parentId,
  }) {
    final categoriesCubit = getIt<TicketCategoriesCubit>();
    if (categoriesCubit.categories.isEmpty) {
      categoriesCubit.getCategories();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: AppText(
                  isSubCategory ? 'اختر التصنيف الفرعي' : 'اختر التصنيف الرئيسي',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              BlocBuilder<TicketCategoriesCubit, TicketsState>(
                bloc: categoriesCubit,
                builder: (_, state) {
                  if (state is TicketsLoading && categoriesCubit.categories.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator());
                  }

                  final list = isSubCategory && parentId != null
                      ? categoriesCubit.categories
                          .where((c) => c.parentId == parentId)
                          .toList()
                      : categoriesCubit.categories
                          .where((c) => c.parentId == null)
                          .toList();

                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppText(isSubCategory
                          ? 'لا توجد تصنيفات فرعية لهذا التصنيف'
                          : 'لا توجد تصنيفات متاحة'),
                    );
                  }

                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final cat = list[index];
                        final isSelected = isSubCategory
                            ? ticket.subCategory?.id == cat.id
                            : ticket.category?.id == cat.id;
                        return ListTile(
                          leading: Icon(
                            isSubCategory
                                ? Icons.account_tree_outlined
                                : Icons.folder_open,
                            color: isSelected
                                ? AppColorScheme.primary
                                : AppColorScheme.grey600,
                          ),
                          title: AppText(cat.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColorScheme.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            if (isSubCategory) {
                              _doUpdate(ticketsCubit, subCategory: cat);
                            } else {
                              _doUpdate(ticketsCubit, category: cat);
                            }
                            _showSuccessSnack(
                                context,
                                isSubCategory
                                    ? 'تم تعيين التصنيف الفرعي: ${cat.name}'
                                    : 'تم تعيين التصنيف: ${cat.name}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helper: build and call updateTicket ─────────────────────────────────────
  void _doUpdate(
    TicketsCubit cubit, {
    String? status,
    dynamic assignedTo,
    dynamic category,
    dynamic subCategory,
  }) {
    final updated = crm_ticket_model.TicketModel(
      id: ticket.id,
      ticketNumber: ticket.ticketNumber,
      title: ticket.title,
      description: ticket.description,
      status: status ?? ticket.status,
      priority: ticket.priority,
      source: ticket.source,
      createdAt: ticket.createdAt,
      closedAt: ticket.closedAt,
      client: ticket.client,
      assignedToId: (assignedTo ?? ticket.assignedTo)?.id,
      assignedTo: assignedTo ?? ticket.assignedTo,
      categoryId: (category ?? ticket.category)?.id,
      category: category ?? ticket.category,
      // when changing main category, clear subcategory
      subCategoryId: category != null ? null : (subCategory ?? ticket.subCategory)?.id,
      subCategory: category != null ? null : (subCategory ?? ticket.subCategory),
    );
    cubit.updateTicket(ticket.id, updated).then((_) {
      if (onUpdate != null) onUpdate!();
    });
  }

  // ── Helper: show success snack ───────────────────────────────────────────────
  void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Small chip widget ────────────────────────────────────────────────────────
  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          AppText(
            text,
            style: TextStyle(
                fontSize: 12, color: color.withOpacity(0.9), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorScheme.grey100.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColorScheme.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          AppText(
            _getPriorityLabel(priority),
            style: const TextStyle(
                fontSize: 11,
                color: AppColorScheme.textMain,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(String source) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorScheme.grey100.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColorScheme.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSourceIcon(source), size: 13, color: AppColorScheme.grey600),
          const SizedBox(width: 4),
          AppText(
            _getSourceLabel(source),
            style: const TextStyle(
                fontSize: 11,
                color: AppColorScheme.textMain,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Label / icon helpers ─────────────────────────────────────────────────────
  String _getStatusLabel(String status) {
    const map = {
      'open': 'مفتوحة',
      'in_progress': 'قيد المعالجة',
      'pending_client': 'بانتظار العميل',
      'resolved': 'تم الحل',
      'closed': 'مغلقة',
    };
    return map[status] ?? status;
  }

  String _getPriorityLabel(String priority) {
    const map = {
      'critical': 'حرجة',
      'high': 'عالية',
      'medium': 'متوسطة',
      'low': 'منخفضة',
    };
    return map[priority] ?? priority;
  }

  String _getSourceLabel(String source) {
    const map = {
      'whatsapp': 'واتساب',
      'phone': 'مكالمة هاتفية',
      'email': 'بريد إلكتروني',
      'manual': 'يدوي',
      'facebook': 'فيسبوك',
      'system': 'النظام',
      'chat_widget': 'محادثة',
      'api': 'API',
    };
    return map[source.toLowerCase()] ?? source;
  }

  IconData _getSourceIcon(String source) {
    final s = source.toLowerCase();
    if (s.contains('whatsapp')) return Icons.chat_outlined;
    if (s.contains('phone') || s.contains('call')) return Icons.phone_outlined;
    if (s.contains('email')) return Icons.email_outlined;
    if (s.contains('facebook') || s.contains('meta')) return Icons.facebook_outlined;
    return Icons.language;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return AppColorScheme.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return AppColorScheme.info;
      default:
        return AppColorScheme.success;
    }
  }
}
