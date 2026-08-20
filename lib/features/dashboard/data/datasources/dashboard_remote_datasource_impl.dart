import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/dashboard_summary_model.dart';
import '../models/dashboard_chart_data_model.dart';
import '../models/recent_activity_model.dart';
import 'dashboard_remote_datasource.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardSummaryModel> getSummary() async {
    final response = await apiClient.get(
      EndPoints.dashboardSummary,
      fromJson: (json) =>
          DashboardSummaryModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<DashboardChartDataModel> getCharts() async {
    final response = await apiClient.get(
      EndPoints.dashboardCharts,
      fromJson: (json) =>
          DashboardChartDataModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<RecentActivityModel>> getRecentActivities() async {
    final response = await apiClient.get(
      EndPoints.dashboardRecentActivities,
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        final List<RecentActivityModel> activities = [];

        if (data['recent_clients'] != null) {
          activities.addAll(
            (data['recent_clients'] as List).map(
              (e) => RecentActivityModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        }
        if (data['recent_invoices'] != null) {
          activities.addAll(
            (data['recent_invoices'] as List).map(
              (e) => RecentActivityModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        }
        if (data['upcoming_appointments'] != null) {
          activities.addAll(
            (data['upcoming_appointments'] as List).map(
              (e) => RecentActivityModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        }
        if (data['recent_comments'] != null) {
          activities.addAll(
            (data['recent_comments'] as List).map(
              (e) => RecentActivityModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        }

        return activities;
      },
    );
    return response.data ?? [];
  }
}
