import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/entities/ticket_category.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_remote_datasource.dart';
import '../models/ticket_model.dart';
import '../models/ticket_category_model.dart';
import '../../../../core/services/network/api_response.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsRemoteDataSource remoteDataSource;

  TicketsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<List<Ticket>>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int page = 1,
  }) async {
    final response = await remoteDataSource.getTickets(
      status: status,
      clientId: clientId,
      assignedTo: assignedTo,
      categoryId: categoryId,
      page: page,
    );
    // Cast from List<TicketModel> to List<Ticket>
    return ApiResponse<List<Ticket>>(
      success: response.success,
      message: response.message,
      data: response.data?.cast<Ticket>(),
      meta: response.meta,
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
    if (category is TicketCategoryModel) {
      return await remoteDataSource.createCategory(category);
    }
    return await remoteDataSource.createCategory(TicketCategoryModel(id: category.id, name: category.name, slaHours: category.slaHours));
  }

  @override
  Future<TicketCategory> updateCategory(int id, TicketCategory category) async {
    if (category is TicketCategoryModel) {
      return await remoteDataSource.updateCategory(id, category);
    }
    return await remoteDataSource.updateCategory(id, TicketCategoryModel(id: category.id, name: category.name, slaHours: category.slaHours));
  }

  @override
  Future<void> deleteCategory(int id) async {
    return await remoteDataSource.deleteCategory(id);
  }
}
