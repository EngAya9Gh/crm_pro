import 'client_enums.dart';
import 'client_file.dart';

class CommentMention {
  final int id;
  final String name;

  CommentMention({required this.id, required this.name});
}

class Comment {
  final String id;
  final String content; // المحتوى (إجباري)
  final String? typeId; // النوع (ديناميكي من API)
  final CommentOutcome? outcome; // النتيجة (اختياري)
  final DateTime? nextFollowUp; // المتابعة القادمة (اختياري)
  final DateTime createdAt;
  final String createdBy;
  final List<ClientFile>? attachments; // الملفات المرفقة
  final List<CommentMention>? mentions; // @الإشارات للموظفين

  Comment({
    required this.id,
    required this.content,
    this.typeId,
    this.outcome,
    this.nextFollowUp,
    required this.createdAt,
    required this.createdBy,
    this.attachments,
    this.mentions,
  });
}
