import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_message.dart';
import '../../domain/entities/ticket_category.dart';

abstract class TicketsState {}

class TicketsInitial extends TicketsState {}

class TicketsLoading extends TicketsState {}

class TicketsLoaded extends TicketsState {
  final List<Ticket> tickets;
  TicketsLoaded(this.tickets);
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
