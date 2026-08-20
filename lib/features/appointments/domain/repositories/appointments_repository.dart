import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../domain/entities/appointment.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, PaginatedList<Appointment>>> getAppointments({
    int page = 1,
    int? limit,
    String? status,
    String? type,
    int? clientId,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, Appointment>> getAppointmentDetails(int id);

  Future<Either<Failure, Appointment>> createAppointment(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Appointment>> updateAppointment(
    int id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Unit>> deleteAppointment(int id);

  Future<Either<Failure, Appointment>> changeAppointmentStatus(
    int id,
    String status,
  );
}
