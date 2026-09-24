import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/entities/ticket_category.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_remote_datasource.dart';
import '../models/ticket_model.dart';
import '../models/ticket_category_model.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsRemoteDataSource remoteDataSource;

  TicketsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Ticket>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int page = 1,
  }) async {
    return await remoteDataSource.getTickets(
      status: status,
      clientId: clientId,
      assignedTo: assignedTo,
      categoryId: categoryId,
      page: page,
    );
  }

  @override
  Future<Ticket> createTicket(Ticket ticket) async {
    return await remoteDataSource.createTicket(ticket as TicketModel);
  }

  @override
  Future<Ticket> updateTicket(int id, Ticket ticket) async {
    return await remoteDataSource.updateTicket(id, ticket as TicketModel);
  }

  @override
  Future<List<TicketMessage>> getTicketMessages(int ticketId) async {
    return await remoteDataSource.getTicketMessages(ticketId);
  }

  @override
  Future<TicketMessage> addTicketMessage(int ticketId, String content, bool isInternal) async {
    return await remoteDataSource.addTicketMessage(ticketId, content, isInternal);
  }

  @override
  Future<List<TicketCategory>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<TicketCategory> createCategory(TicketCategory category) async {
    return await remoteDataSource.createCategory(category as TicketCategoryModel);
  }

  @override
  Future<TicketCategory> updateCategory(int id, TicketCategory category) async {
    return await remoteDataSource.updateCategory(id, category as TicketCategoryModel);
  }

  @override
  Future<void> deleteCategory(int id) async {
    return await remoteDataSource.deleteCategory(id);
  }
}
