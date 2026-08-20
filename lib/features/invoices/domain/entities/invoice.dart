import 'invoice_item.dart';
import '../../../settings/domain/entities/lookup_entities.dart';

class Invoice {
  final int id;
  final String invoiceNumber;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;

  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final String? notes;
  final List<InvoiceItem>? items;
  final int itemsCount;

  final String? clientName;
  final int? clientId; // For creation/linking
  final String? userName;
  final List<TagEntity>? tags;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.total,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.clientName,
    this.clientId,
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discount = 0.0,
    this.notes,
    this.items,
    this.itemsCount = 0,
    this.userName,
    this.tags,
  });
}
