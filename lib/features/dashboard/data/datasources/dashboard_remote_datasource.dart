import '../models/dashboard_summary_model.dart';
import '../models/dashboard_chart_data_model.dart';
import '../models/recent_activity_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
  Future<DashboardChartDataModel> getCharts();
  Future<List<RecentActivityModel>> getRecentActivities();
}
