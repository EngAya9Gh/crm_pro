import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentsRepository repository;

  UpdateAppointmentUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await repository.updateAppointment(id, data);
  }
}
