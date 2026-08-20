import '../../domain/entities/recent_activity.dart';

class RecentActivityModel extends RecentActivity {
  const RecentActivityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.createdAt,
    super.userName,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['link_id'] is int
          ? json['link_id']
          : int.tryParse(json['link_id']?.toString() ?? '0') ?? 0,
      title: json['message']?.toString() ?? json['title']?.toString() ?? '',
      description:
          json['content']?.toString() ?? json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      userName: json['user_name']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      // Handle "2 hours ago" or "2024-02-20" format
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
