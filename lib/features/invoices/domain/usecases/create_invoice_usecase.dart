import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class CreateInvoiceUseCase {
  final InvoicesRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(Map<String, dynamic> data) async {
    return await repository.createInvoice(data);
  }
}
