import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_chart_data.dart';
import '../../domain/entities/recent_activity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardSummary? summary;
  final DashboardChartData? charts;
  final List<RecentActivity> recentActivities;
  final String errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.charts,
    this.recentActivities = const [],
    this.errorMessage = '',
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummary? summary,
    DashboardChartData? charts,
    List<RecentActivity>? recentActivities,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      charts: charts ?? this.charts,
      recentActivities: recentActivities ?? this.recentActivities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    charts,
    recentActivities,
    errorMessage,
  ];
}
