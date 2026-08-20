import 'package:equatable/equatable.dart';

class ClientKPI extends Equatable {
  final int totalClients;
  final int convertedClients;
  final double conversionRate;
  final int hotLeads;
  final double avgConversionDays;
  final double avgResponseTime;
  final double lossRate;

  const ClientKPI({
    this.totalClients = 0,
    this.convertedClients = 0,
    this.conversionRate = 0.0,
    this.hotLeads = 0,
    this.avgConversionDays = 0.0,
    this.avgResponseTime = 0.0,
    this.lossRate = 0.0,
  });

  factory ClientKPI.fromJson(Map<String, dynamic> json) {
    return ClientKPI(
      totalClients: json['total_clients'] ?? 0,
      convertedClients: json['converted_clients'] ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      hotLeads: json['hot_leads'] ?? 0,
      avgConversionDays:
          (json['avg_conversion_days'] as num?)?.toDouble() ?? 0.0,
      avgResponseTime: (json['avg_response_time'] as num?)?.toDouble() ?? 0.0,
      lossRate: (json['loss_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    totalClients,
    convertedClients,
    conversionRate,
    hotLeads,
    avgConversionDays,
    avgResponseTime,
    lossRate,
  ];
}
