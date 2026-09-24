import '../../domain/entities/ticket_message.dart';
import '../../../users/data/models/user_model.dart';

class TicketMessageModel extends TicketMessage {
  TicketMessageModel({
    required super.id,
    required super.content,
    super.isInternal,
    super.user,
    required super.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id'],
      content: json['content'] ?? '',
      isInternal: json['is_internal'] ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'is_internal': isInternal,
    };
  }
}
