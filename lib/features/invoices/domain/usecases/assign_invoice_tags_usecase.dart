import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class AssignInvoiceTagsUseCase {
  final InvoicesRepository repository;

  AssignInvoiceTagsUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(int id, List<int> tagIds) async {
    return await repository.assignInvoiceTags(id, tagIds);
  }
}
