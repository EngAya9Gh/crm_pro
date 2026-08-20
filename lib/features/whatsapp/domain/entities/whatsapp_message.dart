import 'package:equatable/equatable.dart';

class WhatsappMessage extends Equatable {
  final String id;
  final String threadId;
  final String type; // text, image, document, list, template
  final String direction; // inbound, outbound
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final String status; // sent, delivered, read, failed
  final DateTime createdAt;

  const WhatsappMessage({
    required this.id,
    required this.threadId,
    required this.type,
    required this.direction,
    this.content,
    this.mediaUrl,
    this.mediaType,
    required this.status,
    required this.createdAt,
  });

  bool get isMe => direction.toLowerCase() == 'outbound';

  @override
  List<Object?> get props => [
        id,
        threadId,
        type,
        direction,
        content,
        mediaUrl,
        mediaType,
        status,
        createdAt,
      ];
}
