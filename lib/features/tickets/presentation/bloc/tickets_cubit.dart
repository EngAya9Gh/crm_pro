import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/tickets_usecases.dart';
import '../../domain/entities/ticket.dart';
import 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketsUseCase getTicketsUseCase;
  final CreateTicketUseCase createTicketUseCase;
  final UpdateTicketUseCase updateTicketUseCase;
  final GetTicketMessagesUseCase getTicketMessagesUseCase;
  final AddTicketMessageUseCase addTicketMessageUseCase;

  TicketsCubit({
    required this.getTicketsUseCase,
    required this.createTicketUseCase,
    required this.updateTicketUseCase,
    required this.getTicketMessagesUseCase,
    required this.addTicketMessageUseCase,
  }) : super(TicketsInitial());

  Future<void> getTickets({String? status, int? clientId, int? assignedTo, int? categoryId, int page = 1}) async {
    emit(TicketsLoading());
    try {
      final tickets = await getTicketsUseCase(
        status: status,
        clientId: clientId,
        assignedTo: assignedTo,
        categoryId: categoryId,
        page: page,
      );
      emit(TicketsLoaded(tickets));
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> getTicketDetails(Ticket ticket) async {
    emit(TicketsLoading());
    try {
      final messages = await getTicketMessagesUseCase(ticket.id);
      emit(TicketDetailsLoaded(ticket, messages));
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> createTicket(Ticket ticket) async {
    emit(TicketsLoading());
    try {
      await createTicketUseCase(ticket);
      emit(TicketOperationSuccess('تم إنشاء التذكرة بنجاح'));
      getTickets(); // Refresh list
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> updateTicket(int id, Ticket ticket) async {
    emit(TicketsLoading());
    try {
      await updateTicketUseCase(id, ticket);
      emit(TicketOperationSuccess('تم تعديل التذكرة بنجاح'));
      getTickets(); // Refresh list
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> addMessage(Ticket ticket, String content, bool isInternal) async {
    try {
      await addTicketMessageUseCase(ticket.id, content, isInternal);
      // Refresh details
      getTicketDetails(ticket);
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }
}
