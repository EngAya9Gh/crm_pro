class InvoiceItem {
  final int? id;
  final int? productId;
  final String? productName;
  final String description;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double? total;

  InvoiceItem({
    this.id,
    this.productId,
    this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    this.total,
  });
}
