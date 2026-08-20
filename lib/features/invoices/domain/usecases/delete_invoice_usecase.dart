import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoices_repository.dart';

class DeleteInvoiceUseCase {
  final InvoicesRepository repository;

  DeleteInvoiceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int id) async {
    return await repository.deleteInvoice(id);
  }
}
