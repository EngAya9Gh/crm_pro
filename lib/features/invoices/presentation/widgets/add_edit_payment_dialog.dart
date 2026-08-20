import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
// Assuming this exists or using standard Dropdown

class AddEditPaymentDialog extends StatefulWidget {
  final int? paymentId;
  final double? amount;
  final String? method;
  final DateTime? date;
  final String? reference;
  final String? notes;
  final Function(Map<String, dynamic>) onSave;

  const AddEditPaymentDialog({
    super.key,
    this.paymentId,
    this.amount,
    this.method,
    this.date,
    this.reference,
    this.notes,
    required this.onSave,
  });

  @override
  State<AddEditPaymentDialog> createState() => _AddEditPaymentDialogState();
}

class _AddEditPaymentDialogState extends State<AddEditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;
  String _selectedMethod = 'bank_transfer';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.amount?.toString() ?? '',
    );
    _referenceController = TextEditingController(text: widget.reference ?? '');
    _notesController = TextEditingController(text: widget.notes ?? '');
    _selectedMethod = widget.method ?? 'bank_transfer';
    _selectedDate = widget.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(widget.paymentId == null ? 'إضافة دفعة' : 'تعديل الدفعة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _amountController,
                label: 'المبلغ',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                items: const [
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: AppText('تحويل بنكي'),
                  ),
                  DropdownMenuItem(value: 'cash', child: AppText('نقدي')),
                  DropdownMenuItem(
                    value: 'card',
                    child: AppText('بطاقة ائتمان'),
                  ),
                  DropdownMenuItem(value: 'cheque', child: AppText('شيك')),
                ],
                onChanged: (val) => setState(() => _selectedMethod = val!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الاستحقاق',
                  ),
                  child: AppText(
                    '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _referenceController,
                label: 'المرجع (رقم العملية)',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _notesController,
                label: 'ملاحظات',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'amount': double.parse(_amountController.text),
                'payment_method': _selectedMethod,
                'payment_date': _selectedDate.toIso8601String(),
                'reference': _referenceController.text,
                'notes': _notesController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const AppText('حفظ'),
        ),
      ],
    );
  }
}
