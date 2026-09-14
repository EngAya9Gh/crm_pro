import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../models/appointment_model.dart';
import 'appointments_remote_datasource.dart';

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final ApiClient apiClient;

  AppointmentsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedList<AppointmentModel>> getAppointments({
    int page = 1,
    int? limit,
    String? status,
    String? type,
    int? clientId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (page > 1) queryParams['page'] = page;
    if (limit != null && limit != 15) queryParams['per_page'] = limit;

    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (clientId != null) queryParams['client_id'] = clientId;
    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
    }

    final response = await apiClient.get(
      EndPoints.appointments,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => AppointmentModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 15,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<AppointmentModel> getAppointmentDetails(int id) async {
    final response = await apiClient.get(
      EndPoints.appointment(id.toString()),
      fromJson: (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.appointments,
      data: data,
      fromJson: (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<AppointmentModel> updateAppointment(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.appointment(id.toString()),
      data: data,
      fromJson: (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await apiClient.delete(
      EndPoints.appointment(id.toString()),
      fromJson: (json) => null,
    );
  }

  @override
  Future<AppointmentModel> changeAppointmentStatus(
    int id,
    String status, {
    String? note,
  }) async {
    final Map<String, dynamic> data = {'status': status};
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }

    final response = await apiClient.patch(
      EndPoints.appointmentStatus(id.toString()),
      data: data,
      fromJson: (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<AppointmentModel> rescheduleAppointment(
    int id,
    DateTime startAt,
    DateTime endAt, {
    String? note,
  }) async {
    final Map<String, dynamic> data = {
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
    };
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }

    final response = await apiClient.patch(
      '${EndPoints.appointments}/$id/reschedule',
      data: data,
      fromJson: (json) =>
          AppointmentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
