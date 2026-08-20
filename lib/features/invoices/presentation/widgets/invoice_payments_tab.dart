import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/invoice_payment.dart';
import '../bloc/cubits/invoice_payments_cubit.dart';
import 'add_edit_payment_dialog.dart';

class InvoicePaymentsTab extends StatefulWidget {
  final int invoiceId;

  const InvoicePaymentsTab({super.key, required this.invoiceId});

  @override
  State<InvoicePaymentsTab> createState() => _InvoicePaymentsTabState();
}

class _InvoicePaymentsTabState extends State<InvoicePaymentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) =>
          getIt<InvoicePaymentsCubit>()..loadPayments(widget.invoiceId),
      child: _InvoicePaymentsView(invoiceId: widget.invoiceId),
    );
  }
}

class _InvoicePaymentsView extends StatelessWidget {
  final int invoiceId;
  const _InvoicePaymentsView({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'SAR',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: Colors.transparent, // Tab content background
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColorScheme.primary,
        child: const Icon(Icons.add, color: AppColorScheme.white),
      ),
      body: BlocConsumer<InvoicePaymentsCubit, InvoicePaymentsState>(
        listener: (context, state) {
          if (state is InvoicePaymentsOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: AppText(state.message)));
          } else if (state is InvoicePaymentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.message),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoicePaymentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoicePaymentsLoaded) {
            if (state.payments.isEmpty) {
              return const Center(child: AppText('لا توجد دفعات'));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                80,
              ), // Padding for FAB
              itemCount: state.payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final payment = state.payments[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: AppColorScheme.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              currencyFormat.format(payment.amount),
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColorScheme.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                _getMethodLabel(payment.paymentMethod),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              dateFormat.format(payment.paymentDate),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColorScheme.textMuted,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColorScheme.textMuted,
                                  ),
                                  onPressed: () =>
                                      _showEditDialog(context, payment),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: AppColorScheme.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, payment),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (payment.reference != null &&
                            payment.reference!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          AppText(
                            'المرجع: ${payment.reference}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                        if (payment.notes != null &&
                            payment.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          AppText(
                            'ملاحظات: ${payment.notes}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColorScheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is InvoicePaymentsError) {
            return Center(child: AppText(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة ائتمان';
      case 'cheque':
        return 'شيك';
      default:
        return method;
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditPaymentDialog(
        onSave: (data) {
          context.read<InvoicePaymentsCubit>().createPayment(invoiceId, data);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, InvoicePayment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditPaymentDialog(
        paymentId: payment.id,
        amount: payment.amount,
        method: payment.paymentMethod,
        date: payment.paymentDate,
        reference: payment.reference,
        notes: payment.notes,
        onSave: (data) {
          context.read<InvoicePaymentsCubit>().editPayment(
            invoiceId,
            payment.id,
            data,
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, InvoicePayment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف الدفعة'),
        content: const AppText('هل أنت متأكد من حذف هذه الدفعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<InvoicePaymentsCubit>().removePayment(
                invoiceId,
                payment.id,
              );
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
}
