import '../../domain/entities/dashboard_chart_data.dart';

class DashboardChartDataModel extends DashboardChartData {
  const DashboardChartDataModel({
    required super.revenueData,
    required super.clientGrowthData,
  });

  factory DashboardChartDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardChartDataModel(
      revenueData: (json['revenue'] as List? ?? [])
          .map((e) => ChartPointModel.fromJson(e))
          .toList(),
      clientGrowthData: (json['client_growth'] as List? ?? [])
          .map((e) => ChartPointModel.fromJson(e))
          .toList(),
    );
  }
}

class ChartPointModel extends ChartPoint {
  const ChartPointModel({required super.label, required super.value});

  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
    return ChartPointModel(
      label: json['label']?.toString() ?? '',
      value: _toDouble(json['value']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
