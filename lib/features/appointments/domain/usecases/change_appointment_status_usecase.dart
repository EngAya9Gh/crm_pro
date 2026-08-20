import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class ChangeAppointmentStatusUseCase {
  final AppointmentsRepository repository;

  ChangeAppointmentStatusUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(int id, String status) async {
    return await repository.changeAppointmentStatus(id, status);
  }
}
