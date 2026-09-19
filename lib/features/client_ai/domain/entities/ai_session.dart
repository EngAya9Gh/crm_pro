import 'ai_message.dart';

class AiSession {
  final int id;
  final String title;
  final String? type;
  final DateTime createdAt;
  final Map<String, dynamic>? user;
  final List<AiMessage>? messages;
  final String? answer;

  AiSession({
    required this.id,
    required this.title,
    this.type,
    required this.createdAt,
    this.user,
    this.messages,
    this.answer,
  });
}
