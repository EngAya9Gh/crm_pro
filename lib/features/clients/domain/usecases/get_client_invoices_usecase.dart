import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../repositories/clients_repository.dart';

class GetClientInvoicesUseCase {
  final ClientsRepository repository;

  GetClientInvoicesUseCase(this.repository);

  Future<Either<Failure, PaginatedList<Invoice>>> call({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) {
    return repository.getInvoices(
      clientId: clientId,
      page: page,
      perPage: perPage,
    );
  }
}
