import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/tickets_usecases.dart';
import '../../domain/entities/ticket.dart';
import '../../data/models/ticket_model.dart';
import 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketsUseCase getTicketsUseCase;
  final CreateTicketUseCase createTicketUseCase;
  final UpdateTicketUseCase updateTicketUseCase;
  final GetTicketMessagesUseCase getTicketMessagesUseCase;
  final AddTicketMessageUseCase addTicketMessageUseCase;

  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isFetching = false;
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
    int? rating,
    bool refresh = true,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh) {
      _currentPage = 1;
      _allTickets = [];
      emit(TicketsLoading());
    } else {
      emit(TicketsLoaded(_allTickets, meta: null, currentPage: _currentPage, isFetchingMore: true));
    }

    try {
      final response = await getTicketsUseCase(
        status: status,
        clientId: clientId,
        assignedTo: assignedTo,
        categoryId: categoryId,
        rating: rating,
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

      emit(TicketsLoaded(_allTickets, meta: response.meta, currentPage: _currentPage, isFetchingMore: false));
    } catch (e) {
      emit(TicketsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadNextPage({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int? rating,
  }) async {
    if (!_hasMorePages || _isFetching) return;
    _currentPage++;
    await getTickets(
      status: status,
      clientId: clientId,
      assignedTo: assignedTo,
      categoryId: categoryId,
      rating: rating,
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

  /// Updates a ticket without emitting TicketsLoading (so the list stays visible).
  /// Immediately updates the ticket locally (optimistic UI), then calls the API.
  /// On success: emit TicketOperationSuccess then refresh local state.
  /// On failure: rollback to original and emit error.
  Future<void> updateTicket(int id, Ticket ticket) async {
    // --- OPTIMISTIC UPDATE: show the new data immediately ---
    final originalTickets = List<Ticket>.from(_allTickets);
    final mergedTicket = _mergeTicket(ticket, ticket);
    _updateInList(mergedTicket);
    emit(TicketsLoaded(List.from(_allTickets), meta: null, currentPage: _currentPage, isFetchingMore: false));

    try {
      final updatedFromServer = await updateTicketUseCase(id, ticket);
      // Merge server response with what we sent (server may not return relations)
      final finalTicket = _mergeTicket(updatedFromServer, ticket);
      _updateInList(finalTicket);
      emit(TicketOperationSuccess('تم تعديل التذكرة بنجاح'));
      // Emit the refreshed list AFTER the success event
      emit(TicketsLoaded(List.from(_allTickets), meta: null, currentPage: _currentPage, isFetchingMore: false));
    } catch (e) {
      // Rollback on error
      _allTickets = originalTickets;
      emit(TicketsLoaded(List.from(_allTickets), meta: null, currentPage: _currentPage, isFetchingMore: false));
      emit(TicketsError(e.toString()));
    }
  }

  /// Merges [fromServer] with [fromLocal] – prefers server values but falls
  /// back to local values for relations that the server doesn't return.
  TicketModel _mergeTicket(Ticket fromServer, Ticket fromLocal) {
    return TicketModel(
      id: fromServer.id,
      ticketNumber: fromServer.ticketNumber,
      title: fromServer.title,
      description: fromServer.description,
      status: fromServer.status,
      priority: fromServer.priority,
      source: fromServer.source,
      createdAt: fromServer.createdAt,
      closedAt: fromServer.closedAt,
      client: fromServer.client ?? fromLocal.client,
      assignedTo: fromServer.assignedTo ?? fromLocal.assignedTo,
      category: fromServer.category ?? fromLocal.category,
      subCategory: fromServer.subCategory ?? fromLocal.subCategory,
      messages: fromServer.messages ?? fromLocal.messages,
      evaluation: (fromServer is TicketModel && fromServer.evaluation != null)
          ? fromServer.evaluation
          : (fromLocal is TicketModel ? fromLocal.evaluation : null),
      lastMessage: fromServer.lastMessage ?? fromLocal.lastMessage,
    );
  }

  void _updateInList(Ticket ticket) {
    final index = _allTickets.indexWhere((t) => t.id == ticket.id);
    if (index != -1) {
      _allTickets[index] = ticket;
    }
  }

  void updateTicketLocally(Ticket ticket) {
    _updateInList(ticket);
    emit(TicketsLoaded(List.from(_allTickets), meta: null, currentPage: _currentPage, isFetchingMore: false));
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
