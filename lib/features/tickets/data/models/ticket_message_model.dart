import '../../domain/entities/ticket_message.dart';
import '../../../users/data/models/user_model.dart' hide UserModel;
import '../../../users/domain/entities/user.dart';

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
      content: json['content']?.toString() ?? '',
      isInternal: json['is_internal'] == true || json['is_internal'] == 1,
      user: json['user'] != null ? _MessagePartialUser.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'is_internal': isInternal,
    };
  }
}

class _MessagePartialUser extends User {
  const _MessagePartialUser({required super.id, required super.name})
      : super(email: '');

  factory _MessagePartialUser.fromJson(Map<String, dynamic> json) {
    return _MessagePartialUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
    );
  }
}
