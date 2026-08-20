import 'package:equatable/equatable.dart';

class ClientStats extends Equatable {
  final int totalClients;
  final List<StatusStat> byStatus;
  final List<PriorityStat> byPriority;
  final List<SourceStat> bySource;
  final List<InvalidRegistrationStat> invalidRegistrations;
  final List<EmployeePerformanceStat> employeesPerformance;

  const ClientStats({
    this.totalClients = 0,
    this.byStatus = const [],
    this.byPriority = const [],
    this.bySource = const [],
    this.invalidRegistrations = const [],
    this.employeesPerformance = const [],
  });

  @override
  List<Object?> get props => [
    totalClients,
    byStatus,
    byPriority,
    bySource,
    invalidRegistrations,
    employeesPerformance,
  ];
}

class StatusStat extends Equatable {
  final int? statusId;
  final String statusName;
  final String color;
  final int count;

  const StatusStat({
    required this.statusName,
    required this.count,
    this.statusId,
    this.color = '#000000',
  });

  factory StatusStat.fromJson(Map<String, dynamic> json) {
    return StatusStat(
      statusId: json['status_id'],
      statusName: json['status_name'] ?? '',
      color: json['color'] ?? '#000000',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [statusId, statusName, color, count];
}

class PriorityStat extends Equatable {
  final String priority;
  final int count;

  const PriorityStat({required this.priority, required this.count});

  factory PriorityStat.fromJson(Map<String, dynamic> json) {
    return PriorityStat(
      priority: json['priority'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [priority, count];
}

class SourceStat extends Equatable {
  final int? sourceId;
  final String sourceName;
  final int count;

  const SourceStat({
    required this.sourceName,
    required this.count,
    this.sourceId,
  });

  factory SourceStat.fromJson(Map<String, dynamic> json) {
    return SourceStat(
      sourceId: json['source_id'],
      sourceName: json['source_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [sourceId, sourceName, count];
}

class InvalidRegistrationStat extends Equatable {
  final int? reasonId;
  final String reasonName;
  final int count;

  const InvalidRegistrationStat({
    required this.reasonName,
    required this.count,
    this.reasonId,
  });

  factory InvalidRegistrationStat.fromJson(Map<String, dynamic> json) {
    return InvalidRegistrationStat(
      reasonId: json['reason_id'],
      reasonName: json['reason_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [reasonId, reasonName, count];
}

class EmployeePerformanceStat extends Equatable {
  final int userId;
  final String userName;
  final int totalAssigned;
  final int convertedCount;
  final double conversionRate;

  const EmployeePerformanceStat({
    required this.userId,
    required this.userName,
    required this.totalAssigned,
    required this.convertedCount,
    required this.conversionRate,
  });

  factory EmployeePerformanceStat.fromJson(Map<String, dynamic> json) {
    // Handle conversionRate being int or double from JSON
    final rate = json['conversion_rate'];
    double parsedRate = 0.0;
    if (rate is int) {
      parsedRate = rate.toDouble();
    } else if (rate is double) {
      parsedRate = rate;
    }

    return EmployeePerformanceStat(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      totalAssigned: json['total_assigned'] ?? 0,
      convertedCount: json['converted_count'] ?? 0,
      conversionRate: parsedRate,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    userName,
    totalAssigned,
    convertedCount,
    conversionRate,
  ];
}
