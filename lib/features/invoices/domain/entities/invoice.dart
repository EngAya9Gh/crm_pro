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

  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? paidAt,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    String? notes,
    List<InvoiceItem>? items,
    int? itemsCount,
    String? clientName,
    int? clientId,
    String? userName,
    List<TagEntity>? tags,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      itemsCount: itemsCount ?? this.itemsCount,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      userName: userName ?? this.userName,
      tags: tags ?? this.tags,
    );
  }
}
