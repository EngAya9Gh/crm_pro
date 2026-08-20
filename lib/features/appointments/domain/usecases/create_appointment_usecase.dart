import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentsRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(Map<String, dynamic> data) async {
    return await repository.createAppointment(data);
  }
}
