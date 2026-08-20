import '../../domain/entities/whatsapp_thread.dart';
import 'whatsapp_message_model.dart';

class WhatsappThreadModel extends WhatsappThread {
  const WhatsappThreadModel({
    required super.id,
    super.clientId,
    super.clientName,
    super.clientPhone,
    required super.status,
    required super.unreadCount,
    super.lastMessage,
    required super.updatedAt,
  });

  factory WhatsappThreadModel.fromJson(Map<String, dynamic> json) {
    return WhatsappThreadModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clientId: json['clientId'] ?? json['client_id'],
      clientName: json['contactName'] ?? json['client_name'] ?? json['client']?['name'],
      clientPhone: json['contactPhone'] ?? json['phone'] ?? json['client']?['phone'],
      status: json['status'] ?? 'active',
      unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      lastMessage: json['last_message'] != null
          ? WhatsappMessageModel.fromJson(json['last_message'])
          : null,
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : DateTime.now(),
    );
  }
}
