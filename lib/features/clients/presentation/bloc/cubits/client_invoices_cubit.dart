import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crm_wakeel/features/invoices/domain/entities/invoice.dart';
import 'package:crm_wakeel/features/clients/domain/usecases/get_client_invoices_usecase.dart';

// States
abstract class ClientInvoicesState extends Equatable {
  const ClientInvoicesState();
  @override
  List<Object?> get props => [];
}

class ClientInvoicesInitial extends ClientInvoicesState {}

class ClientInvoicesLoading extends ClientInvoicesState {}

class ClientInvoicesLoaded extends ClientInvoicesState {
  final List<Invoice> invoices;
  final bool hasReachedMax;
  final int page;

  const ClientInvoicesLoaded(
    this.invoices, {
    this.hasReachedMax = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [invoices, hasReachedMax, page];

  ClientInvoicesLoaded copyWith({
    List<Invoice>? invoices,
    bool? hasReachedMax,
    int? page,
  }) {
    return ClientInvoicesLoaded(
      invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }
}

class ClientInvoicesError extends ClientInvoicesState {
  final String message;
  const ClientInvoicesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ClientInvoicesCubit extends Cubit<ClientInvoicesState> {
  final GetClientInvoicesUseCase getClientInvoices;

  static const int _pageSize = 10;
  int _currentPage = 1;

  ClientInvoicesCubit(this.getClientInvoices) : super(ClientInvoicesInitial());

  Future<void> loadInvoices(String clientId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      emit(ClientInvoicesLoading());
    } else if (state is ClientInvoicesLoaded) {
      // Don't emit loading if we already have data (for silent refresh or init check)
    } else {
      emit(ClientInvoicesLoading());
    }

    final result = await getClientInvoices(
      clientId: clientId,
      page: _currentPage,
      perPage: _pageSize,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ClientInvoicesError(failure.message)),
      (paginatedList) => emit(
        ClientInvoicesLoaded(
          paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> loadMoreInvoices(String clientId) async {
    if (state is! ClientInvoicesLoaded) return;

    final currentState = state as ClientInvoicesLoaded;
    if (currentState.hasReachedMax) return;

    _currentPage++;

    final result = await getClientInvoices(
      clientId: clientId,
      page: _currentPage,
      perPage: _pageSize,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _currentPage--; // Revert page on error
        // Optionally emit error or just ignore for pagination
      },
      (paginatedList) {
        emit(
          currentState.copyWith(
            invoices: List.of(currentState.invoices)
              ..addAll(paginatedList.items),
            hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
            page: paginatedList.currentPage,
          ),
        );
      },
    );
  }
}
