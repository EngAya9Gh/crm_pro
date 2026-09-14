import '../../../../core/common/models/paginated_list.dart';
import '../models/appointment_model.dart';

abstract class AppointmentsRemoteDataSource {
  Future<PaginatedList<AppointmentModel>> getAppointments({
    int page = 1,
    int? limit,
    String? status,
    String? type,
    int? clientId,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<AppointmentModel> getAppointmentDetails(int id);

  Future<AppointmentModel> createAppointment(Map<String, dynamic> data);

  Future<AppointmentModel> updateAppointment(int id, Map<String, dynamic> data);

  Future<void> deleteAppointment(int id);

  Future<AppointmentModel> rescheduleAppointment(
    int id,
    DateTime startAt,
    DateTime endAt, {
    String? note,
  });

  Future<AppointmentModel> changeAppointmentStatus(
    int id,
    String status, {
    String? note,
  });
}
