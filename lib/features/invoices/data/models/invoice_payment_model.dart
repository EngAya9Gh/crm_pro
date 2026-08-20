import '../../domain/entities/invoice_payment.dart';

class InvoicePaymentModel extends InvoicePayment {
  const InvoicePaymentModel({
    required super.id,
    required super.amount,
    required super.paymentMethod,
    required super.paymentDate,
    super.reference,
    super.notes,
    super.createdBy,
    required super.createdAt,
  });

  factory InvoicePaymentModel.fromJson(Map<String, dynamic> json) {
    return InvoicePaymentModel(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      paymentDate: DateTime.parse(json['payment_date']),
      reference: json['reference'],
      notes: json['notes'],
      createdBy: json['user']?['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
