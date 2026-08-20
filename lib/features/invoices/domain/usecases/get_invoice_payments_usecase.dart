import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoice_payments_repository.dart';
import '../entities/invoice_payment.dart';

class GetInvoicePaymentsUseCase {
  final InvoicePaymentsRepository repository;

  GetInvoicePaymentsUseCase(this.repository);

  Future<Either<Failure, List<InvoicePayment>>> call(int invoiceId) async {
    return await repository.getPayments(invoiceId);
  }
}
