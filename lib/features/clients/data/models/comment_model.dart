import '../../domain/entities/client_enums.dart';
import '../../domain/entities/comment.dart';
import 'client_file_model.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.content,
    super.typeId,
    super.outcome,
    super.nextFollowUp,
    required super.createdAt,
    required super.createdBy,
    super.attachments,
    super.mentions,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      typeId: json['type_id']?.toString(),
      outcome: json['outcome'] != null ? _parseOutcome(json['outcome']) : null,
      nextFollowUp: json['next_follow_up'] != null
          ? DateTime.tryParse(json['next_follow_up'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      createdBy:
          json['user']?['name'] ?? json['created_by']?.toString() ?? 'Unknown',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
                .map((e) => ClientFileModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      mentions: json['mentions'] != null
          ? (json['mentions'] as List)
                .map(
                  (e) => CommentMention(
                    id: e['id'] as int,
                    name: e['name'] as String,
                  ),
                )
                .toList()
          : null,
    );
  }

  static CommentOutcome? _parseOutcome(String value) {
    try {
      return CommentOutcome.values.byName(value);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type_id': typeId,
      'outcome': outcome?.name,
      'next_follow_up': nextFollowUp?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'attachments': attachments,
      'mentions': mentions,
    };
  }
}
