import '../../domain/entities/dashboard_chart_data.dart';

class DashboardChartDataModel extends DashboardChartData {
  const DashboardChartDataModel({
    required super.revenueData,
    required super.clientGrowthData,
    required super.sourceDistribution,
  });

  factory DashboardChartDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardChartDataModel(
      revenueData: (json['revenue_trend'] as List? ?? [])
          .map((e) => ChartPointModel.fromJson(e, valueKey: 'total', labelKey: 'label'))
          .toList(),
      clientGrowthData: (json['clients_trend'] as List? ?? [])
          .map((e) => ChartPointModel.fromJson(e, valueKey: 'count', labelKey: 'label'))
          .toList(),
      sourceDistribution: (json['source_distribution'] as List? ?? [])
          .map((e) => ChartPointModel.fromJson(e, valueKey: 'count', labelKey: 'source'))
          .toList(),
    );
  }
}

class ChartPointModel extends ChartPoint {
  const ChartPointModel({required super.label, required super.value});

  factory ChartPointModel.fromJson(Map<String, dynamic> json, {String valueKey = 'value', String labelKey = 'label'}) {
    return ChartPointModel(
      label: json[labelKey]?.toString() ?? '',
      value: _toDouble(json[valueKey]),
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
