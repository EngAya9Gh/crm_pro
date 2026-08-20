import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/invoices_repository.dart';

class DownloadInvoicePdfUseCase {
  final InvoicesRepository repository;

  DownloadInvoicePdfUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int id, String savePath) async {
    return await repository.downloadInvoicePdf(id, savePath);
  }
}
