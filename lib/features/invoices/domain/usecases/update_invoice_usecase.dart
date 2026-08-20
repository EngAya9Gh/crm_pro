import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class UpdateInvoiceUseCase {
  final InvoicesRepository repository;

  UpdateInvoiceUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await repository.updateInvoice(id, data);
  }
}
