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
  });
}
