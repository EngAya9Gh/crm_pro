import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/entities/ticket_category.dart';
import '../../../../core/services/network/api_response.dart';

abstract class TicketsState {}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<Ticket> tickets;
  final PaginationMeta? meta;
  final int currentPage;
  TicketsLoaded(this.tickets, {this.meta, this.currentPage = 1});
}

class TicketDetailsLoaded extends TicketsState {
  final Ticket ticket;
  final List<TicketMessage> messages;
  TicketDetailsLoaded(this.ticket, this.messages);
}

class TicketCategoriesLoaded extends TicketsState {
  final List<TicketCategory> categories;
  TicketCategoriesLoaded(this.categories);
}

class TicketsError extends TicketsState {
  final String message;
  TicketsError(this.message);
}

class TicketOperationSuccess extends TicketsState {
  final String message;
  TicketOperationSuccess(this.message);
}
