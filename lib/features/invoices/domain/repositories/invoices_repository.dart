import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../domain/entities/invoice.dart';

abstract class InvoicesRepository {
  Future<Either<Failure, PaginatedList<Invoice>>> getInvoices({
    int page = 1,
    int? limit,
    String? status,
    int? clientId,
    int? userId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, Invoice>> getInvoiceDetails(int id);

  Future<Either<Failure, Invoice>> createInvoice(Map<String, dynamic> data);

  Future<Either<Failure, Invoice>> updateInvoice(
    int id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Unit>> deleteInvoice(int id);

  Future<Either<Failure, Invoice>> changeInvoiceStatus(int id, String status);

  Future<Either<Failure, Unit>> sendInvoice(int id, List<String> channels);

  Future<Either<Failure, Unit>> downloadInvoicePdf(int id, String savePath);
}
