import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class GetInvoiceDetailsUseCase {
  final InvoicesRepository repository;

  GetInvoiceDetailsUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(int id) async {
    return await repository.getInvoiceDetails(id);
  }
}
