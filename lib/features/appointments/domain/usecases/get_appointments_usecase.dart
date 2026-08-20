import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentsRepository repository;

  GetAppointmentsUseCase(this.repository);

  Future<Either<Failure, PaginatedList<Appointment>>> call({
    int page = 1,
    int? limit,
    String? status,
    String? type,
    int? clientId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await repository.getAppointments(
      page: page,
      limit: limit,
      status: status,
      type: type,
      clientId: clientId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
