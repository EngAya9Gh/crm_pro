import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/entities/ticket_category.dart';

abstract class TicketsRepository {
  Future<List<Ticket>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int page = 1,
  });

  Future<Ticket> createTicket(Ticket ticket);
  Future<Ticket> updateTicket(int id, Ticket ticket);

  Future<List<TicketMessage>> getTicketMessages(int ticketId);
  Future<TicketMessage> addTicketMessage(int ticketId, String content, bool isInternal);

  Future<List<TicketCategory>> getCategories();
  Future<TicketCategory> createCategory(TicketCategory category);
  Future<TicketCategory> updateCategory(int id, TicketCategory category);
  Future<void> deleteCategory(int id);
}
