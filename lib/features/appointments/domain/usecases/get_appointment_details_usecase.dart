import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointments_repository.dart';

class GetAppointmentDetailsUseCase {
  final AppointmentsRepository repository;

  GetAppointmentDetailsUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(int id) async {
    return await repository.getAppointmentDetails(id);
  }
}
