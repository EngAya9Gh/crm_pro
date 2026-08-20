import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import 'add_edit_invoice_screen.dart';
import '../widgets/invoice_payments_tab.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  String? _downloadedFilePath;

  @override
  void initState() {
    super.initState();
    context.read<InvoicesBloc>().add(GetInvoiceDetailsEvent(widget.invoiceId));
  }

  Future<void> _downloadPdf() async {
    try {
      String savePath;
      if (kIsWeb) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savePath = 'invoice_${widget.invoiceId}_$timestamp.pdf';
      } else {
        final dir = await getTemporaryDirectory();
        final fileName =
            'invoice_${widget.invoiceId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        savePath = '${dir.path}/$fileName';
      }

      setState(() {
        _downloadedFilePath = savePath;
      });

      if (!mounted) return;
      context.read<InvoicesBloc>().add(
        DownloadInvoicePdfEvent(widget.invoiceId, savePath),
      );
    } catch (e) {
      debugPrint('PDF Download Error: $e');
      if (!mounted) return;

      String message = 'خطأ في تحديد مسار الملف: $e';
      if (e.toString().contains('MissingPluginException')) {
        message =
            'يرجى إعادة تشغيل التطبيق بالكامل (Restart) لتفعيل ميزة التحميل';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'تفاصيل الفاتورة',
        bottom: const TabBar(
          labelColor: AppColorScheme.primary,
          unselectedLabelColor: AppColorScheme.textMuted,
          indicatorColor: AppColorScheme.primary,
          tabs: [
            Tab(text: 'التفاصيل'),
            Tab(text: 'الدفعات'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColorScheme.textMain),
            onSelected: (value) {
              final bloc = context.read<InvoicesBloc>();
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: AddEditInvoiceScreen(
                          invoiceId: widget.invoiceId,
                        ),
                      ),
                    ),
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
                case 'send':
                  _showSendDialog(context);
                  break;
                case 'download':
                  _downloadPdf();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    AppText('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'send',
                child: Row(
                  children: [
                    Icon(Icons.send_outlined, size: 18),
                    SizedBox(width: 8),
                    AppText('إرسال'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, size: 18),
                    SizedBox(width: 8),
                    AppText('تحميل PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColorScheme.error,
                    ),
                    SizedBox(width: 8),
                    AppText(
                      'حذف',
                      style: TextStyle(color: AppColorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        body: BlocListener<InvoicesBloc, InvoicesState>(
          listener: (context, state) {
            if (state.operationStatus == InvoiceOperationStatus.success) {
              // Handle PDF Open
              if (state.operationMessage.contains('PDF') &&
                  _downloadedFilePath != null) {
                OpenFilex.open(_downloadedFilePath!);
              }

              if (state.operationMessage.contains('حذف')) {
                Navigator.pop(context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.operationMessage)),
              );
            } else if (state.operationStatus ==
                InvoiceOperationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppText(state.operationMessage),
                  backgroundColor: AppColorScheme.error,
                ),
              );
            }
          },
          child: TabBarView(
            children: [
              _buildDetailsTab(),
              InvoicePaymentsTab(invoiceId: widget.invoiceId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return BlocBuilder<InvoicesBloc, InvoicesState>(
      builder: (context, state) {
        if (state.detailStatus == InvoicesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.detailStatus == InvoicesStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColorScheme.error,
                ),
                const SizedBox(height: 16),
                AppText(
                  state.errorMessage,
                  style: const TextStyle(color: AppColorScheme.error),
                ),
              ],
            ),
          );
        }

        final invoice = state.invoiceDetail;
        if (invoice == null) {
          return const Center(child: AppText('لا توجد بيانات'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColorScheme.surface, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          invoice.invoiceNumber,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(invoice.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (invoice.clientName != null) ...[
                      _buildInfoRow('العميل', invoice.clientName!),
                      const SizedBox(height: 8),
                    ],
                    _buildInfoRow(
                      'تاريخ الإصدار',
                      _formatDate(invoice.createdAt),
                    ),
                    if (invoice.dueDate != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'تاريخ الاستحقاق',
                        _formatDate(invoice.dueDate!),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Financial Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColorScheme.surface, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'الملخص المالي',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmountRow('المجموع الفرعي', invoice.subtotal),
                    const SizedBox(height: 8),
                    _buildAmountRow(
                      'الضريبة (${invoice.taxRate}%)',
                      invoice.taxAmount,
                    ),
                    if (invoice.discount > 0) ...[
                      const SizedBox(height: 8),
                      _buildAmountRow('الخصم', -invoice.discount),
                    ],
                    const Divider(height: 24),
                    _buildAmountRow('الإجمالي', invoice.total, isTotal: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Items
              if (invoice.items != null && invoice.items!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColorScheme.surface, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'البنود',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...invoice.items!.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      item.description,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} ر.س',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColorScheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppText(
                                '${(item.quantity * item.unitPrice - item.discount).toStringAsFixed(2)} ر.س',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColorScheme.surface, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'ملاحظات',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        invoice.notes!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'paid':
        color = AppColorScheme.success;
        label = 'مدفوعة';
        break;
      case 'pending':
        color = AppColorScheme.warning;
        label = 'معلقة';
        break;
      case 'overdue':
        color = AppColorScheme.error;
        label = 'متأخرة';
        break;
      case 'draft':
        color = AppColorScheme.silver;
        label = 'مسودة';
        break;
      default:
        color = AppColorScheme.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColorScheme.textMuted,
          ),
        ),
        AppText(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: isTotal
              ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
              : AppTypography.bodyMedium,
        ),
        AppText(
          '${amount.toStringAsFixed(2)} ر.س',
          style: isTotal
              ? AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorScheme.primary,
                )
              : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context) {
    final bloc = context.read<InvoicesBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف الفاتورة'),
        content: const AppText('هل أنت متأكد من حذف هذه الفاتورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeleteInvoiceEvent(widget.invoiceId));
              Navigator.pop(ctx);
            },
            child: const AppText(
              'حذف',
              style: TextStyle(color: AppColorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSendDialog(BuildContext context) {
    final bloc = context.read<InvoicesBloc>();
    final channels = <String>[];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const AppText('إرسال الفاتورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const AppText('واتساب'),
                value: channels.contains('whatsapp'),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      channels.add('whatsapp');
                    } else {
                      channels.remove('whatsapp');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const AppText('رسالة نصية'),
                value: channels.contains('sms'),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      channels.add('sms');
                    } else {
                      channels.remove('sms');
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const AppText('إلغاء'),
            ),
            ElevatedButton(
              onPressed: channels.isEmpty
                  ? null
                  : () {
                      bloc.add(SendInvoiceEvent(widget.invoiceId, channels));
                      Navigator.pop(ctx);
                    },
              child: const AppText('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
