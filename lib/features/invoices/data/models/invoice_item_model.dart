import 'package:crm_wakeel/features/invoices/domain/entities/invoice_item.dart';

class InvoiceItemModel extends InvoiceItem {
  InvoiceItemModel({
    super.id,
    super.productId,
    super.productName,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    super.discount = 0.0,
    super.total,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      description: json['description'] ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      // Total is usually calculated by backend or frontend, but if sending:
    };
  }
}
