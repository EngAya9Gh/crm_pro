import 'package:crm_wakeel/features/invoices/domain/entities/invoice.dart';
import 'package:crm_wakeel/features/invoices/data/models/invoice_item_model.dart';
import '../../../../features/settings/data/models/lookup_models.dart';

class InvoiceModel extends Invoice {
  InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.total,
    required super.status,
    required super.createdAt,
    super.dueDate,
    super.paidAt,
    super.clientName,
    super.clientId,
    super.subtotal,
    super.taxRate,
    super.taxAmount,
    super.discount,
    super.notes,
    super.items,
    super.itemsCount = 0,
    super.userName,
    super.tags,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      itemsCount: int.tryParse(json['items_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      clientName: json['client'] is Map
          ? json['client']['name']
          : json['client_name'],
      clientId: json['client'] is Map
          ? int.tryParse(json['client']['id']?.toString() ?? '0')
          : int.tryParse(json['client_id']?.toString() ?? '0'),
      userName: json['user'] is Map ? json['user']['name'] : null,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List)
                .map((i) => InvoiceItemModel.fromJson(i))
                .toList()
          : null,
      tags:
          (json['tags'] ?? json['invoice_tags'] ?? json['invoiceTags']) != null
          ? ((json['tags'] ?? json['invoice_tags'] ?? json['invoiceTags'])
                    as List)
                .map((t) => TagModel.fromJson(t))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'total': total.toStringAsFixed(2),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'client_id': clientId,
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'discount': discount,
      'notes': notes,
      if (items != null)
        'items': items!.map((e) => (e as InvoiceItemModel).toJson()).toList(),
    };
  }
}
