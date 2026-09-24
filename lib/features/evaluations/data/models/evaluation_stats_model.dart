import '../../domain/entities/evaluation_stats.dart';

class EvaluationStatsModel extends EvaluationStats {
  EvaluationStatsModel({
    required super.average,
    required super.total,
    required super.distribution,
  });

  factory EvaluationStatsModel.fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};
    if (json['distribution'] != null) {
      (json['distribution'] as Map<String, dynamic>).forEach((key, value) {
        distribution[int.parse(key)] = value;
      });
    }

    return EvaluationStatsModel(
      average: json['average'] != null ? (json['average'] as num).toDouble() : 0.0,
      total: json['total'] ?? 0,
      distribution: distribution,
    );
  }
}
