import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_dropdown.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import '../../../settings/domain/entities/product.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/bloc/lookups_bloc.dart';
import '../../../settings/presentation/bloc/lookups_event.dart';
import '../../../settings/presentation/bloc/lookups_state.dart';
import '../../../../core/services/di/di_container.dart';

class AddEditInvoiceScreen extends StatefulWidget {
  final int? invoiceId;

  const AddEditInvoiceScreen({super.key, this.invoiceId});

  @override
  State<AddEditInvoiceScreen> createState() => _AddEditInvoiceScreenState();
}

class _AddEditInvoiceScreenState extends State<AddEditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedClientId;
  int? _selectedEmployeeId;
  final _notesController = TextEditingController();
  final _taxRateController = TextEditingController(text: '15');
  final _discountController = TextEditingController(text: '0');

  final List<InvoiceItemInput> _items = [];
  String _selectedStatus = 'draft';
  DateTime? _dueDate;
  DateTime _invoiceDate = DateTime.now();

  bool _isDataPopulated = false;

  bool get isEdit => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    context.read<InvoicesBloc>().add(const GetInvoiceClientsEvent());
    context.read<InvoicesBloc>().add(GetInvoiceProductsEvent());

    if (isEdit) {
      context.read<InvoicesBloc>().add(
        GetInvoiceDetailsEvent(widget.invoiceId!),
      );
    } else {
      _addItem(); // Add first empty item
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItemInput());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('يجب إضافة بند واحد على الأقل')),
      );
      return;
    }
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText('الرجاء اختيار العميل')));
      return;
    }

    final data = {
      'client_id': _selectedClientId,
      'status': _selectedStatus,
      'invoice_date': DateFormat('yyyy-MM-dd').format(_invoiceDate),
      'due_date': _dueDate != null
          ? DateFormat('yyyy-MM-dd').format(_dueDate!)
          : null,
      'tax_rate': double.tryParse(_taxRateController.text) ?? 0,
      'discount': double.tryParse(_discountController.text) ?? 0,
      'notes': _notesController.text,
      'user_id': _selectedEmployeeId,
      'items': _items
          .map(
            (item) => {
              'product_id': item.selectedProductId,
              'description': item.descriptionController.text,
              'quantity': int.tryParse(item.quantityController.text) ?? 1,
              'unit_price': double.tryParse(item.priceController.text) ?? 0,
            },
          )
          .toList(),
    };

    if (isEdit) {
      context.read<InvoicesBloc>().add(
        UpdateInvoiceEvent(widget.invoiceId!, data),
      );
    } else {
      context.read<InvoicesBloc>().add(CreateInvoiceEvent(data));
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _items) {
      int qty = int.tryParse(item.quantityController.text) ?? 0;
      double price = double.tryParse(item.priceController.text) ?? 0;
      total += qty * price;
    }
    return total;
  }

  double get _totalAfterDiscount {
    double discount = double.tryParse(_discountController.text) ?? 0;
    return _subtotal - discount;
  }

  double get _taxAmount {
    double rate = double.tryParse(_taxRateController.text) ?? 0;
    return _totalAfterDiscount * (rate / 100);
  }

  double get _grandTotal {
    return _totalAfterDiscount + _taxAmount;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<LookupsBloc>()..add(LoadAllLookups()),
      child: AppScaffold(
        title: isEdit ? 'تعديل الفاتورة' : 'فاتورة جديدة',
        body: BlocConsumer<InvoicesBloc, InvoicesState>(
        listener: (context, state) {
          if (state.operationStatus == InvoiceOperationStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: AppText(state.operationMessage)));
            Navigator.pop(context);
          } else if (state.operationStatus == InvoiceOperationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.operationMessage),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }

          // Populate data in Edit Mode
          if (isEdit &&
              !_isDataPopulated &&
              state.detailStatus == InvoicesStatus.success &&
              state.invoiceDetail != null) {
            final invoice = state.invoiceDetail!;
            setState(() {
              _selectedClientId = invoice.clientId;
              _selectedStatus = invoice.status.toLowerCase();
              _invoiceDate = invoice.createdAt;
              _dueDate = invoice.dueDate;
              _taxRateController.text = invoice.taxRate.toString();
              _discountController.text = invoice.discount.toString();
              _notesController.text = invoice.notes ?? '';

              _items.clear();
              if (invoice.items != null && invoice.items!.isNotEmpty) {
                for (var item in invoice.items!) {
                  final input = InvoiceItemInput();
                  input.selectedProductId = item.productId;
                  input.descriptionController.text = item.description;
                  input.quantityController.text = item.quantity.toString();
                  input.priceController.text = item.unitPrice.toString();
                  input.addListener(() {
                    setState(() {});
                  }); // Listen for changes to update totals
                  _items.add(input);
                }
              } else {
                final input = InvoiceItemInput();
                input.addListener(() {
                  setState(() {});
                });
                _items.add(input);
              }

              _isDataPopulated = true;
            });
          }
        },
        builder: (context, state) {
          if (state.operationStatus == InvoiceOperationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    title: 'بيانات العميل والفاتورة',
                    children: [
                      if (state.isClientsLoading)
                        const LinearProgressIndicator()
                      else
                        AppDropdown<int>(
                          label: 'العميل',
                          hint: 'اختر العميل',
                          value: _selectedClientId,
                          legacyItems: () {
                            final items = state.clientList.map((client) {
                              return DropdownMenuItem<int>(
                                value: client.id,
                                child: AppText(client.name),
                              );
                            }).toList();

                            // If editing and selected client is not in the fetched list, add it temporarily
                            if (isEdit &&
                                _selectedClientId != null &&
                                !state.clientList.any(
                                  (c) => c.id == _selectedClientId,
                                )) {
                              items.add(
                                DropdownMenuItem<int>(
                                  value: _selectedClientId,
                                  child: AppText(
                                    state.invoiceDetail?.clientName ??
                                        'غير معروف',
                                  ),
                                ),
                              );
                            }
                            return items;
                          }(),
                          itemLabel: (id) {
                            if (isEdit &&
                                id == _selectedClientId &&
                                !state.clientList.any((c) => c.id == id)) {
                              return state.invoiceDetail?.clientName ??
                                  'غير معروف';
                            }
                            final client = state.clientList
                                .where((c) => c.id == id)
                                .firstOrNull;
                            return client?.name ?? '';
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedClientId = value;
                            });
                          },
                          validator: (value) => value == null ? 'مطلوب' : null,
                        ),
                      const SizedBox(height: 16),
                      BlocBuilder<LookupsBloc, LookupsState>(
                        builder: (context, lookupsState) {
                          if (lookupsState is LookupsLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (lookupsState is LookupsLoaded) {
                            return AppDropdown<int?>(
                              label: 'الموظف المسؤول (اختياري)',
                              hint: 'اختر الموظف',
                              value: _selectedEmployeeId,
                              items: [
                                const AppDropdownItem<int?>(
                                  value: null,
                                  label: 'بدون تحديد',
                                ),
                                ...lookupsState.employees.map((emp) {
                                  return AppDropdownItem<int?>(
                                    value: emp.id,
                                    label: emp.name,
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedEmployeeId = val;
                                });
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'الحالة',
                              value: _selectedStatus,
                              showSearchBox: false,
                              legacyItems: const [
                                DropdownMenuItem(
                                  value: 'draft',
                                  child: AppText('مسودة'),
                                ),
                                DropdownMenuItem(
                                  value: 'sent',
                                  child: AppText('مرسلة'),
                                ),
                                DropdownMenuItem(
                                  value: 'paid',
                                  child: AppText('مدفوعة'),
                                ),
                              ],
                              itemLabel: (value) {
                                switch (value) {
                                  case 'draft':
                                    return 'مسودة';
                                  case 'sent':
                                    return 'مرسلة';
                                  case 'paid':
                                    return 'مدفوعة';
                                  default:
                                    return value;
                                }
                              },
                              onChanged: (value) {
                                setState(() => _selectedStatus = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDatePicker(
                              context,
                              label: 'تاريخ الاستحقاق',
                              selectedDate: _dueDate,
                              onDateSelected: (date) =>
                                  setState(() => _dueDate = date),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'البنود',
                    action: TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const AppText('إضافة بند'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColorScheme.primary,
                      ),
                    ),
                    children: _items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      // Attach listener if not attached (hacky but handles adding new items)
                      // Ideally handled in _addItem
                      return _buildItemCard(index, item, state.productList);
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'الماليات والملاحظات',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _taxRateController,
                              label: 'الضريبة (%)',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _discountController,
                              label: 'الخصم',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _notesController,
                        label: 'ملاحظات',
                        hintText: 'أدخل ملاحظات إضافية',
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Live Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'المجموع الفرعي',
                          _subtotal,
                          isWhite: true,
                        ),
                        _buildSummaryRow(
                          'الخصم',
                          _totalAfterDiscount - _subtotal,
                          isWhite: true,
                        ), // Show negative diff
                        _buildSummaryRow(
                          'الضريبة (${_taxRateController.text}%)',
                          _taxAmount,
                          isWhite: true,
                        ),
                        const Divider(color: Colors.white54, height: 24),
                        _buildSummaryRow(
                          'الإجمالي النهائي',
                          _grandTotal,
                          isWhite: true,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: AppText(
                      isEdit ? 'حفظ التعديلات' : 'إنشاء الفاتورة',
                      style: const TextStyle(
                        color: AppColorScheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (action != null) action,
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorScheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate)
                      : 'ختر التاريخ',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null
                        ? AppColorScheme.textMain
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isWhite = false,
    bool isTotal = false,
  }) {
    final color = isWhite ? Colors.white : AppColorScheme.textMain;
    final style = TextStyle(
      color: color,
      fontSize: isTotal ? 18 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, style: style),
          AppText(
            NumberFormat.currency(
              symbol: 'SAR ',
              decimalDigits: 2,
            ).format(amount),
            style: style,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    int index,
    InvoiceItemInput item,
    List<Product> products,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorScheme.grey200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorScheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  '#${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_items.length > 1)
                InkWell(
                  onTap: () => _removeItem(index),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColorScheme.error,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Product Selector
          DropdownButtonFormField<int>(
            value: products.any((p) => p.id == item.selectedProductId)
                ? item.selectedProductId
                : null,
            decoration: InputDecoration(
              labelText: 'المنتج / الخدمة',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: products
                .map(
                  (p) => DropdownMenuItem<int>(
                    value: p.id,
                    child: AppText(p.name),
                  ),
                )
                .toList(),
            onChanged: (productId) {
              if (productId == null) return;
              final productIdx = products.indexWhere((p) => p.id == productId);
              if (productIdx == -1) return;
              final product = products[productIdx];

              item.descriptionController.text = product.name;
              item.priceController.text = product.price.toString();

              if (item.selectedProductId != productId) {
                setState(() {
                  item.selectedProductId = productId;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          AppTextField(
            controller: item.descriptionController,
            label: 'الوصف',
            hintText: 'وصف الخدمة',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: item.quantityController,
                  label: 'الكمية',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: item.priceController,
                  label: 'السعر',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Item Total
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const AppText(
                'المجموع: ',
                style: TextStyle(color: AppColorScheme.textMuted, fontSize: 12),
              ),
              AppText(
                NumberFormat.currency(symbol: 'SAR').format(
                  (double.tryParse(item.priceController.text) ?? 0) *
                      (int.tryParse(item.quantityController.text) ?? 0),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvoiceItemInput extends ChangeNotifier {
  int? selectedProductId;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController priceController = TextEditingController();

  InvoiceItemInput() {
    descriptionController.addListener(notifyListeners);
    quantityController.addListener(notifyListeners);
    priceController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
