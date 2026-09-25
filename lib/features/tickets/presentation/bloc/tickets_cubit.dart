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

  int _currentPage = 1;
  bool _hasMorePages = false;
  List<Ticket> _allTickets = [];

  TicketsCubit({
    required this.getTicketsUseCase,
    required this.createTicketUseCase,
    required this.updateTicketUseCase,
    required this.getTicketMessagesUseCase,
    required this.addTicketMessageUseCase,
  }) : super(TicketsInitial());

  Future<void> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    bool refresh = true,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _allTickets = [];
      emit(TicketsLoading());
    }

    try {
      final response = await getTicketsUseCase(
        status: status,
        clientId: clientId,
        assignedTo: assignedTo,
        categoryId: categoryId,
        page: _currentPage,
      );

      if (response.data != null) {
        if (refresh) {
          _allTickets = response.data!;
        } else {
          _allTickets = [..._allTickets, ...response.data!];
        }
        _hasMorePages = response.meta != null && _currentPage < response.meta!.lastPage;
      }

      emit(TicketsLoaded(_allTickets, meta: response.meta, currentPage: _currentPage));
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> loadNextPage({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
  }) async {
    if (!_hasMorePages) return;
    _currentPage++;
    await getTickets(
      status: status,
      clientId: clientId,
      assignedTo: assignedTo,
      categoryId: categoryId,
      refresh: false,
    );
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
      getTickets();
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> updateTicket(int id, Ticket ticket) async {
    emit(TicketsLoading());
    try {
      await updateTicketUseCase(id, ticket);
      emit(TicketOperationSuccess('تم تعديل التذكرة بنجاح'));
      getTickets();
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> addMessage(Ticket ticket, String content, bool isInternal) async {
    try {
      await addTicketMessageUseCase(ticket.id, content, isInternal);
      getTicketDetails(ticket);
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }
}
