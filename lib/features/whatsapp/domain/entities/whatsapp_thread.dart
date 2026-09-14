import 'package:equatable/equatable.dart';
import 'whatsapp_message.dart';

class WhatsappThread extends Equatable {
  final String id;
  final int? clientId;
  final String? clientName;
  final String? clientPhone;
  final String status;
  final int unreadCount;
  final WhatsappMessage? lastMessage;
  final DateTime updatedAt;

  const WhatsappThread({
    required this.id,
    this.clientId,
    this.clientName,
    this.clientPhone,
    required this.status,
    required this.unreadCount,
    this.lastMessage,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    clientId,
    clientName,
    clientPhone,
    status,
    unreadCount,
    lastMessage,
    updatedAt,
  ];
}
