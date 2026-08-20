import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice_payment.dart';

abstract class InvoicePaymentsRepository {
  Future<Either<Failure, List<InvoicePayment>>> getPayments(int invoiceId);

  Future<Either<Failure, InvoicePayment>> addPayment(
    int invoiceId,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, InvoicePayment>> updatePayment(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Unit>> deletePayment(int invoiceId, int paymentId);
}
