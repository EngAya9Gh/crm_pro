import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../repositories/clients_repository.dart';

class GetClientAppointmentsUseCase {
  final ClientsRepository repository;

  GetClientAppointmentsUseCase(this.repository);

  Future<Either<Failure, PaginatedList<Appointment>>> call({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) {
    return repository.getAppointments(
      clientId: clientId,
      page: page,
      perPage: perPage,
    );
  }
}
