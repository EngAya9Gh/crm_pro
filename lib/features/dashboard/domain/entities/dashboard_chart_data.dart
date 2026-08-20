import 'package:equatable/equatable.dart';

class DashboardChartData extends Equatable {
  final List<ChartPoint> revenueData;
  final List<ChartPoint> clientGrowthData;

  const DashboardChartData({
    required this.revenueData,
    required this.clientGrowthData,
  });

  @override
  List<Object?> get props => [revenueData, clientGrowthData];
}

class ChartPoint extends Equatable {
  final String label;
  final double value;

  const ChartPoint({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}
