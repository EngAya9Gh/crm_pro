import 'package:equatable/equatable.dart';

class InvoicePayment extends Equatable {
  final int id;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;

  const InvoicePayment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.reference,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    paymentMethod,
    paymentDate,
    reference,
    notes,
    createdBy,
    createdAt,
  ];
}
