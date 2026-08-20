import '../../domain/entities/whatsapp_message.dart';

class WhatsappMessageModel extends WhatsappMessage {
  const WhatsappMessageModel({
    required super.id,
    required super.threadId,
    required super.type,
    required super.direction,
    super.content,
    super.mediaUrl,
    super.mediaType,
    required super.status,
    required super.createdAt,
  });

  factory WhatsappMessageModel.fromJson(Map<String, dynamic> json) {
    return WhatsappMessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      threadId: json['threadId']?.toString() ?? json['thread_id']?.toString() ?? '',
      type: json['type'] ?? 'text',
      direction: json['direction'] ?? 'inbound',
      content: json['content'] ?? json['message'], // backend might return 'content' or 'message'
      mediaUrl: json['mediaUrl'] ?? json['media_url'] ?? json['file_url'],
      mediaType: json['mediaType'] ?? json['media_type'],
      status: json['status'] ?? 'sent',
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
    );
  }
}
