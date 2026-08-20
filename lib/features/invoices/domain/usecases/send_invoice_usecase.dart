import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoices_repository.dart';

class SendInvoiceUseCase {
  final InvoicesRepository repository;

  SendInvoiceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int id, List<String> channels) async {
    return await repository.sendInvoice(id, channels);
  }
}
