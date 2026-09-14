import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../domain/entities/invoice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../settings/domain/entities/lookup_entities.dart';
import '../../../settings/presentation/bloc/lookups_bloc.dart';
import '../../../settings/presentation/bloc/lookups_state.dart';
import '../../../settings/presentation/bloc/lookups_event.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceCard({super.key, required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = intl.NumberFormat.currency(
      symbol: 'SAR',
      decimalDigits: 2,
    );
    final dateFormat = intl.DateFormat('yyyy-MM-dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header: Invoice # & Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorScheme.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            invoice.invoiceNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          AppText(
                            dateFormat.format(invoice.createdAt),
                            style: const TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusBadge(invoice.status),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'tag',
                            child: Row(
                              children: [
                                const Icon(Icons.sell_outlined, size: 20),
                                const SizedBox(width: 8),
                                const AppText('إضافة وسم'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'status',
                            child: Row(
                              children: [
                                const Icon(Icons.sync_alt, size: 20),
                                const SizedBox(width: 8),
                                const AppText('تغيير الحالة'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'tag') {
                            _showTagDialog(context);
                          } else if (value == 'status') {
                            _showStatusDialog(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body: Client & Financials
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'العميل',
                            style: TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            invoice.clientName ?? '---',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const AppText(
                            'المبلغ الإجمالي',
                            style: TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            currencyFormat.format(invoice.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (invoice.tags != null && invoice.tags!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: invoice.tags!
                          .map((tag) => _buildTagChip(tag))
                          .toList(),
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColorScheme.grey200),
                  ),

                  // Info Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.inventory_2_outlined,
                        '${invoice.itemsCount} بنود',
                      ),
                      if (invoice.dueDate != null)
                        _buildInfoItem(
                          Icons.calendar_today_outlined,
                          'استحقاق: ${dateFormat.format(invoice.dueDate!)}',
                          isWarning: _isOverdue(invoice),
                        ),
                      if (invoice.userName != null)
                        _buildInfoItem(Icons.person_outline, invoice.userName!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(Invoice invoice) {
    if (invoice.status.toLowerCase() == 'paid') return false;
    if (invoice.dueDate == null) return false;
    return invoice.dueDate!.isBefore(DateTime.now());
  }

  Widget _buildInfoItem(IconData icon, String text, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isWarning ? AppColorScheme.error : AppColorScheme.textMuted,
        ),
        const SizedBox(width: 4),
        AppText(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isWarning ? AppColorScheme.error : AppColorScheme.textMuted,
            fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        color = AppColorScheme.success;
        label = 'مدفوعة';
        icon = Icons.check_circle_outline;
        break;
      case 'partially_paid':
        color = AppColorScheme.warning;
        label = 'جزئياً';
        icon = Icons.hourglass_top_rounded;
        break;
      case 'draft':
        color = Colors.grey;
        label = 'مسودة';
        icon = Icons.edit_note;
        break;
      case 'sent':
        color = AppColorScheme.info; // Assuming info color exists or use blue
        label = 'مرسلة';
        icon = Icons.send_outlined;
        break;
      case 'overdue':
        color = AppColorScheme.error;
        label = 'متأخرة';
        icon = Icons.warning_amber_rounded;
        break;
      case 'cancelled':
        color = Colors.redAccent;
        label = 'ملغاة';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = AppColorScheme.textMuted;
        label = status;
        icon = Icons.info_outline;
    }

    // Use a defined safe color if AppColorScheme details are missing, assuming common ones exist
    // If AppColorScheme.info is not defined, fallback to blue
    if (status.toLowerCase() == 'sent') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          AppText(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(TagEntity tag) {
    final color = _parseColor(tag.color, fallbackName: tag.name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText(
        tag.name,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showTagDialog(BuildContext context) {
    final lookupsBloc = context.read<LookupsBloc>();
    final invoicesBloc = context.read<InvoicesBloc>();

    final lookupsState = lookupsBloc.state;
    if (lookupsState is! LookupsLoaded) {
      if (lookupsState is LookupsInitial || lookupsState is LookupsError) {
        lookupsBloc.add(LoadAllLookups());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('جاري تحميل الوسوم، يرجى المحاولة بعد قليل...'),
        ),
      );
      return;
    }

    final allTags = lookupsState.lookups.invoiceTags;
    List<TagEntity> selectedTags = List.from(invoice.tags ?? []);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const AppText('وسوم الفاتورة'),
              content: SizedBox(
                width: double.maxFinite,
                child: allTags.isEmpty
                    ? const Center(child: AppText('لا توجد وسوم متاحة'))
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allTags.map((tag) {
                            final isSelected = selectedTags.any(
                              (selected) => selected.id == tag.id,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
                                    selectedTags.add(
                                      TagEntity(
                                        id: tag.id,
                                        name: tag.name,
                                        color: tag.color,
                                      ),
                                    );
                                  } else {
                                    selectedTags.removeWhere(
                                      (t) => t.id == tag.id,
                                    );
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const AppText('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    invoicesBloc.add(
                      AssignInvoiceTagsEvent(
                        invoice.id,
                        selectedTags.map((t) => t.id).toList(),
                      ),
                    );
                  },
                  child: const AppText('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context) {
    final invoicesBloc = context.read<InvoicesBloc>();
    final currentStatus = invoice.status;
    final List<String> availableStatuses = [
      'draft',
      'sent',
      'paid',
      'partially_paid',
      'overdue',
      'cancelled',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const AppText('تغيير حالة الفاتورة'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableStatuses.map((status) {
                  return RadioListTile<String>(
                    title: AppText(status),
                    value: status,
                    groupValue: currentStatus,
                    onChanged: (value) {
                      if (value != null && value != currentStatus) {
                        Navigator.pop(ctx);
                        invoicesBloc.add(
                          ChangeInvoiceStatusEvent(invoice.id, value),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const AppText('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String hexColor, {String? fallbackName}) {
    if ((hexColor == '#000000' || hexColor.isEmpty) && fallbackName != null) {
      // Generate a pleasant color based on the tag name
      final colors = [
        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
        Colors.green,
      ];
      final hash = fallbackName.codeUnits.fold(0, (prev, curr) => prev + curr);
      return colors[hash % colors.length];
    }

    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppColorScheme.primary;
    }
  }
}
