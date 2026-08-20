import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointments_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentsRepository repository;

  DeleteAppointmentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int id) async {
    return await repository.deleteAppointment(id);
  }
}
