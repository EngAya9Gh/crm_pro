import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class ChangeInvoiceStatusUseCase {
  final InvoicesRepository repository;

  ChangeInvoiceStatusUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(int id, String status) async {
    return await repository.changeInvoiceStatus(id, status);
  }
}
