import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoice_payments_repository.dart';

class DeleteInvoicePaymentUseCase {
  final InvoicePaymentsRepository repository;

  DeleteInvoicePaymentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int invoiceId, int paymentId) async {
    return await repository.deletePayment(invoiceId, paymentId);
  }
}
