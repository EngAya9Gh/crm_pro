import '../entities/ticket.dart';
import '../entities/ticket_message.dart';
import '../entities/ticket_category.dart';
import '../repositories/tickets_repository.dart';
import '../../../../core/services/network/api_response.dart';

class GetTicketsUseCase {
  final TicketsRepository repository;
  GetTicketsUseCase(this.repository);
  Future<ApiResponse<List<Ticket>>> call({String? status, int? clientId, int? assignedTo, int? categoryId, int? rating, int page = 1}) {
    return repository.getTickets(status: status, clientId: clientId, assignedTo: assignedTo, categoryId: categoryId, rating: rating, page: page);
  }
}

class CreateTicketUseCase {
  final TicketsRepository repository;
  CreateTicketUseCase(this.repository);
  Future<Ticket> call(Ticket ticket) {
    return repository.createTicket(ticket);
  }
}

class UpdateTicketUseCase {
  final TicketsRepository repository;
  UpdateTicketUseCase(this.repository);
  Future<Ticket> call(int id, Ticket ticket) {
    return repository.updateTicket(id, ticket);
  }
}

class GetTicketMessagesUseCase {
  final TicketsRepository repository;
  GetTicketMessagesUseCase(this.repository);
  Future<List<TicketMessage>> call(int ticketId) {
    return repository.getTicketMessages(ticketId);
  }
}

class AddTicketMessageUseCase {
  final TicketsRepository repository;
  AddTicketMessageUseCase(this.repository);
  Future<TicketMessage> call(int ticketId, String content, bool isInternal) {
    return repository.addTicketMessage(ticketId, content, isInternal);
  }
}

class GetTicketCategoriesUseCase {
  final TicketsRepository repository;
  GetTicketCategoriesUseCase(this.repository);
  Future<List<TicketCategory>> call() {
    return repository.getCategories();
  }
}

class CreateTicketCategoryUseCase {
  final TicketsRepository repository;
  CreateTicketCategoryUseCase(this.repository);
  Future<TicketCategory> call(TicketCategory category) {
    return repository.createCategory(category);
  }
}

class UpdateTicketCategoryUseCase {
  final TicketsRepository repository;
  UpdateTicketCategoryUseCase(this.repository);
  Future<TicketCategory> call(int id, TicketCategory category) {
    return repository.updateCategory(id, category);
  }
}

class DeleteTicketCategoryUseCase {
  final TicketsRepository repository;
  DeleteTicketCategoryUseCase(this.repository);
  Future<void> call(int id) {
    return repository.deleteCategory(id);
  }
}
