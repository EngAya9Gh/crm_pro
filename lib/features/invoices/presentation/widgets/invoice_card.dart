import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../domain/entities/invoice.dart';
import 'package:intl/intl.dart' as intl;
import '../../../settings/domain/entities/lookup_entities.dart';

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
                  _buildStatusBadge(invoice.status),
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
    final color = _parseColor(tag.color);
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

  Color _parseColor(String hexColor) {
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
