import 'package:flutter_bloc/flutter_bloc.dart';
import 'invoices_event.dart';
import 'invoices_state.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/usecases/get_invoice_details_usecase.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/update_invoice_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/change_invoice_status_usecase.dart';
import '../../domain/usecases/send_invoice_usecase.dart';
import '../../domain/usecases/download_invoice_pdf_usecase.dart';

import '../../../clients/domain/usecases/get_clients_list_usecase.dart';
import '../../../settings/domain/usecases/settings_usecases.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final GetInvoicesUseCase getInvoices;
  final GetInvoiceDetailsUseCase getInvoiceDetails;
  final CreateInvoiceUseCase createInvoice;
  final UpdateInvoiceUseCase updateInvoice;
  final DeleteInvoiceUseCase deleteInvoice;
  final ChangeInvoiceStatusUseCase changeStatus;
  final SendInvoiceUseCase sendInvoice;
  final DownloadInvoicePdfUseCase downloadPdf;
  final GetClientsListUseCase getClientsList;
  final GetProductsUseCase getProducts;

  // ... (existing filter state)
  // Filter state for load more
  String? _currentStatus;
  int? _currentClientId;
  String? _currentSearch;
  DateTime? _currentDateFrom;
  DateTime? _currentDateTo;

  static const int? _limit = null;

  InvoicesBloc({
    required this.getInvoices,
    required this.getInvoiceDetails,
    required this.createInvoice,
    required this.updateInvoice,
    required this.deleteInvoice,
    required this.changeStatus,
    required this.sendInvoice,
    required this.downloadPdf,
    required this.getClientsList,
    required this.getProducts,
  }) : super(const InvoicesState()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadMoreInvoices>(_onLoadMoreInvoices);
    on<GetInvoiceDetailsEvent>(_onGetInvoiceDetails);
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<UpdateInvoiceEvent>(_onUpdateInvoice);
    on<DeleteInvoiceEvent>(_onDeleteInvoice);
    on<ChangeInvoiceStatusEvent>(_onChangeStatus);
    on<SendInvoiceEvent>(_onSendInvoice);
    on<DownloadInvoicePdfEvent>(_onDownloadPdf);
    on<GetInvoiceClientsEvent>(_onGetInvoiceClients);
    on<GetInvoiceProductsEvent>(_onGetInvoiceProducts);
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<InvoicesState> emit,
  ) async {
    if (event.isRefresh) {
      emit(
        state.copyWith(
          status: InvoicesStatus.loading,
          invoices: [],
          page: 1,
          hasReachedMax: false,
        ),
      );
    } else {
      emit(state.copyWith(status: InvoicesStatus.loading));
    }

    _currentStatus = event.status;
    _currentClientId = event.clientId;
    _currentSearch = event.search;
    _currentDateFrom = event.dateFrom;
    _currentDateTo = event.dateTo;

    final result = await getInvoices(
      page: 1,
      limit: _limit,
      status: event.status,
      clientId: event.clientId,
      search: event.search,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: InvoicesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginatedList) => emit(
        state.copyWith(
          status: InvoicesStatus.success,
          invoices: paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreInvoices(
    LoadMoreInvoices event,
    Emitter<InvoicesState> emit,
  ) async {
    if (state.hasReachedMax || state.status != InvoicesStatus.success) return;

    final result = await getInvoices(
      page: state.page + 1,
      limit: _limit,
      status: _currentStatus,
      clientId: _currentClientId,
      search: _currentSearch,
      dateFrom: _currentDateFrom,
      dateTo: _currentDateTo,
    );

    result.fold(
      (failure) =>
          null, // Ignore error on pagination for now or show snackbar via listener?
      (paginatedList) => emit(
        state.copyWith(
          invoices: List.of(state.invoices)..addAll(paginatedList.items),
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onGetInvoiceDetails(
    GetInvoiceDetailsEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(detailStatus: InvoicesStatus.loading));
    final result = await getInvoiceDetails(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailStatus: InvoicesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (invoice) => emit(
        state.copyWith(
          detailStatus: InvoicesStatus.success,
          invoiceDetail: invoice,
        ),
      ),
    );
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: InvoiceOperationStatus.loading,
        operationMessage: '',
      ),
    );
    final result = await createInvoice(event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (invoice) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.success,
          operationMessage: 'تم إنشاء الفاتورة بنجاح',
          // Optionally prepend to list
          invoices: [invoice, ...state.invoices],
        ),
      ),
    );
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoiceEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: InvoiceOperationStatus.loading,
        operationMessage: '',
      ),
    );
    final result = await updateInvoice(event.id, event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (invoice) {
        // Update item in list
        final updatedList = state.invoices
            .map((e) => e.id == invoice.id ? invoice : e)
            .toList();

        emit(
          state.copyWith(
            operationStatus: InvoiceOperationStatus.success,
            operationMessage: 'تم تحديث الفاتورة بنجاح',
            invoices: updatedList,
            invoiceDetail: invoice, // Update detail content too if verified
          ),
        );
      },
    );
  }

  Future<void> _onDeleteInvoice(
    DeleteInvoiceEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: InvoiceOperationStatus.loading));
    final result = await deleteInvoice(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (_) {
        final updatedList = state.invoices
            .where((e) => e.id != event.id)
            .toList();
        emit(
          state.copyWith(
            operationStatus: InvoiceOperationStatus.success,
            operationMessage: 'تم حذف الفاتورة',
            invoices: updatedList,
          ),
        );
      },
    );
  }

  Future<void> _onChangeStatus(
    ChangeInvoiceStatusEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    // Optimistic or Loading? Loading is safer.
    emit(state.copyWith(operationStatus: InvoiceOperationStatus.loading));
    final result = await changeStatus(event.id, event.status);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (invoice) {
        final updatedList = state.invoices
            .map((e) => e.id == invoice.id ? invoice : e)
            .toList();
        emit(
          state.copyWith(
            operationStatus: InvoiceOperationStatus.success,
            operationMessage: 'تم تحديث الحالة',
            invoices: updatedList,
            invoiceDetail: invoice,
          ),
        );
      },
    );
  }

  Future<void> _onSendInvoice(
    SendInvoiceEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: InvoiceOperationStatus.loading));
    final result = await sendInvoice(event.id, event.channels);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.success,
          operationMessage: 'تم إرسال الفاتورة',
        ),
      ),
    );
  }

  Future<void> _onDownloadPdf(
    DownloadInvoicePdfEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: InvoiceOperationStatus.loading));
    final result = await downloadPdf(event.id, event.savePath);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          operationStatus: InvoiceOperationStatus.success,
          operationMessage: 'تم تحميل PDF بنجاح',
        ),
      ),
    );
  }

  Future<void> _onGetInvoiceClients(
    GetInvoiceClientsEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(isClientsLoading: true));
    final result = await getClientsList(
      search: event.search,
      perPage: 50, // Higher limit for dropdown
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isClientsLoading: false, errorMessage: failure.message),
      ),
      (list) =>
          emit(state.copyWith(isClientsLoading: false, clientList: list.items)),
    );
  }

  Future<void> _onGetInvoiceProducts(
    GetInvoiceProductsEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(state.copyWith(isProductsLoading: true));
    final result = await getProducts();
    result.fold(
      (failure) => emit(
        state.copyWith(isProductsLoading: false, errorMessage: failure.message),
      ),
      (list) =>
          emit(state.copyWith(isProductsLoading: false, productList: list)),
    );
  }
}
