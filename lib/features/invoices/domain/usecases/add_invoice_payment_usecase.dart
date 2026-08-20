import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoice_payments_repository.dart';
import '../entities/invoice_payment.dart';

class AddInvoicePaymentUseCase {
  final InvoicePaymentsRepository repository;

  AddInvoicePaymentUseCase(this.repository);

  Future<Either<Failure, InvoicePayment>> call(
    int invoiceId,
    Map<String, dynamic> data,
  ) async {
    return await repository.addPayment(invoiceId, data);
  }
}
