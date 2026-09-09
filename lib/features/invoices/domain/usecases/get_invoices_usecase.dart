import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

class GetInvoicesUseCase {
  final InvoicesRepository repository;

  GetInvoicesUseCase(this.repository);

  Future<Either<Failure, PaginatedList<Invoice>>> call({
    int page = 1,
    int? limit,
    String? status,
    int? clientId,
    int? userId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    List<int>? tagIds,
  }) async {
    return await repository.getInvoices(
      page: page,
      limit: limit,
      status: status,
      clientId: clientId,
      userId: userId,
      search: search,
      dateFrom: dateFrom,
      dateTo: dateTo,
      tagIds: tagIds,
    );
  }
}
