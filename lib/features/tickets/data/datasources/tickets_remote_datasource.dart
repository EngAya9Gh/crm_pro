import '../models/ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../models/ticket_category_model.dart';

abstract class TicketsRemoteDataSource {
  Future<List<TicketModel>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int page = 1,
  });

  Future<TicketModel> createTicket(TicketModel ticket);
  Future<TicketModel> updateTicket(int id, TicketModel ticket);

  Future<List<TicketMessageModel>> getTicketMessages(int ticketId);
  Future<TicketMessageModel> addTicketMessage(int ticketId, String content, bool isInternal);

  Future<List<TicketCategoryModel>> getCategories();
  Future<TicketCategoryModel> createCategory(TicketCategoryModel category);
  Future<TicketCategoryModel> updateCategory(int id, TicketCategoryModel category);
  Future<void> deleteCategory(int id);
}
