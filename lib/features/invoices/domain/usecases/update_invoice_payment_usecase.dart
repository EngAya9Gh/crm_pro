import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoice_payments_repository.dart';
import '../entities/invoice_payment.dart';

class UpdateInvoicePaymentUseCase {
  final InvoicePaymentsRepository repository;

  UpdateInvoicePaymentUseCase(this.repository);

  Future<Either<Failure, InvoicePayment>> call(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    return await repository.updatePayment(invoiceId, paymentId, data);
  }
}
