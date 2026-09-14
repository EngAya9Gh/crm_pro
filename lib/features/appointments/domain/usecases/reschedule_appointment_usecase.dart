import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class RescheduleAppointmentUseCase {
  final AppointmentsRepository repository;

  RescheduleAppointmentUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(
    int id,
    DateTime startAt,
    DateTime endAt, {
    String? note,
  }) async {
    return await repository.rescheduleAppointment(
      id,
      startAt,
      endAt,
      note: note,
    );
  }
}
