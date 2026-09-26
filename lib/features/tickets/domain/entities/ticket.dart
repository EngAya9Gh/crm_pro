import '../../../clients/domain/entities/client.dart';
import '../../../users/domain/entities/user.dart';
import 'ticket_category.dart';
import 'ticket_message.dart';

class Ticket {
  final int id;
  final String ticketNumber;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String source;
  final DateTime? slaDueAt;
  final Client? client;
  final User? assignedTo;
  final TicketCategory? category;
  final TicketCategory? subCategory;
  final List<TicketMessage>? messages;
  final DateTime createdAt;
  final DateTime? closedAt;
  final Map<String, dynamic>? evaluation;
  final String? lastMessage;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.source,
    this.slaDueAt,
    this.client,
    this.assignedTo,
    this.category,
    this.subCategory,
    this.messages,
    required this.createdAt,
    this.closedAt,
    this.evaluation,
    this.lastMessage,
  });

  Ticket copyWith({
    int? id,
    String? ticketNumber,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? source,
    DateTime? slaDueAt,
    Client? client,
    User? assignedTo,
    TicketCategory? category,
    TicketCategory? subCategory,
    List<TicketMessage>? messages,
    DateTime? createdAt,
    DateTime? closedAt,
    Map<String, dynamic>? evaluation,
    String? lastMessage,
    int? assignedToId,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      slaDueAt: slaDueAt ?? this.slaDueAt,
      client: client ?? this.client,
      assignedTo: assignedTo ?? this.assignedTo,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      evaluation: evaluation ?? this.evaluation,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
