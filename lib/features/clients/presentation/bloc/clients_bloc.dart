import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_clients_usecase.dart';
import '../../domain/usecases/get_client_stats_usecase.dart';

import '../../domain/usecases/add_client_usecase.dart';
import '../../domain/usecases/update_client_usecase.dart';
import '../../domain/usecases/update_clients_bulk_status_usecase.dart'
    as uc_update;
import '../../domain/usecases/assign_clients_bulk_usecase.dart' as uc_assign;
import '../../domain/usecases/delete_clients_bulk_usecase.dart' as uc_delete;
import '../../domain/usecases/delete_client_usecase.dart';
import '../../domain/usecases/upload_client_file_usecase.dart';
import '../../domain/entities/saved_filter.dart';
import 'clients_event.dart';
import 'clients_state.dart';

import '../../domain/usecases/get_client_kpis_usecase.dart';
import '../../domain/usecases/download_client_pdf.dart';
import '../../domain/usecases/save_filter_usecase.dart';
import '../../domain/usecases/get_saved_filters_usecase.dart';
import '../../domain/usecases/delete_saved_filter_usecase.dart';

import '../../domain/usecases/get_client_comments_usecase.dart';
import 'package:crm_wakeel/features/clients/domain/usecases/get_client_timeline_usecase.dart';
import 'package:crm_wakeel/features/clients/domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/export_clients_usecase.dart';
import '../../domain/usecases/get_client_invoices_usecase.dart';
import '../../domain/usecases/get_client_appointments_usecase.dart';
import '../../domain/usecases/get_client_files_usecase.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final GetClients getClients;
  final GetClientStats? getClientStats;
  final GetClientKPIs? getClientKPIs;
  final AddClient? addClient;
  final UpdateClient? updateClient;
  final uc_update.UpdateClientsBulkStatus? updateBulkStatus;
  final uc_assign.AssignClientsBulk? assignBulk;
  final uc_delete.DeleteClientsBulk? deleteBulk;
  final DeleteClient? deleteClient;

  final UploadClientFile? uploadFile;
  final DownloadClientPdf? downloadClientPdf;
  final SaveFilterUseCase? saveFilter;
  final GetSavedFilters? getSavedFilters;
  final DeleteSavedFilter? deleteSavedFilter;

  final GetClientCommentsUseCase? getClientComments;
  final GetClientTimelineUseCase? getClientTimeline;
  final AddComment? addComment;
  final ExportClientsUseCase? exportClients;

  final GetClientInvoicesUseCase? getClientInvoices;
  final GetClientAppointmentsUseCase? getClientAppointments;
  final GetClientFilesUseCase? getClientFiles;

  List<SavedFilter> _savedFilters = [];
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Comments pagination state
  int _commentsPage = 1;
  static const int _commentsPageSize = 10;

  // Invoices pagination state
  int _invoicesPage = 1;
  static const int _invoicesPageSize = 10;

  // Appointments pagination state
  int _appointmentsPage = 1;
  static const int _appointmentsPageSize = 10;

  ClientsBloc({
    required this.getClients,
    this.getClientStats,
    this.getClientKPIs,
    this.addClient,
    this.updateClient,
    this.updateBulkStatus,
    this.assignBulk,
    this.deleteBulk,
    this.deleteClient,
    this.uploadFile,
    this.downloadClientPdf,
    this.saveFilter,
    this.getSavedFilters,
    this.deleteSavedFilter,
    this.getClientComments,
    this.getClientTimeline,
    this.addComment,
    this.exportClients,
    this.getClientInvoices,
    this.getClientAppointments,
    this.getClientFiles,
  }) : super(ClientsInitial()) {
    on<LoadClients>(_onLoadClients);
    on<RefreshClients>(_onRefreshClients);
    on<SearchClients>(_onSearchClients);
    on<LoadClientStats>(_onLoadClientStats);
    on<LoadClientKPIs>(_onLoadClientKPIs);
    on<AddClientEvent>(_onAddClient);
    on<UpdateClientEvent>(_onUpdateClient);
    on<LoadMoreClients>(_onLoadMoreClients);
    on<UpdateClientsBulkStatus>(_onUpdateBulkStatus);
    on<AssignClientsBulk>(_onAssignBulk);
    on<DeleteClientsBulk>(_onDeleteBulk);
    on<DeleteClientEvent>(_onDeleteClient);
    on<UploadClientFileEvent>(_onUploadClientFile);
    on<DownloadClientPdfEvent>(_onDownloadClientPdf);
    on<SaveFilterEvent>(_onSaveFilter);
    on<LoadSavedFilters>(_onLoadSavedFilters);
    on<DeleteSavedFilterEvent>(_onDeleteSavedFilter);
    on<LoadClientComments>(_onLoadClientComments);
    on<LoadMoreClientComments>(_onLoadMoreClientComments);
    on<LoadClientTimeline>(_onLoadClientTimeline);
    on<AddClientCommentEvent>(_onAddClientComment);
    on<ExportClientsEvent>(_onExportClients);

    // New Handlers
    on<LoadClientInvoices>(_onLoadClientInvoices);
    on<LoadMoreClientInvoices>(_onLoadMoreClientInvoices);
    on<LoadClientAppointments>(_onLoadClientAppointments);
    on<LoadMoreClientAppointments>(_onLoadMoreClientAppointments);
    on<LoadClientFiles>(_onLoadClientFiles);
  }

  Future<void> _onExportClients(
    ExportClientsEvent event,
    Emitter<ClientsState> emit,
  ) async {
    print('ClientsBloc: ExportClientsEvent received. UseCase: $exportClients');
    if (exportClients == null) {
      print('ClientsBloc: ExportClientsUseCase is NULL!');
      return;
    }

    // We don't want to replace the whole list view with loading, so maybe show loading in UI via other means
    // But standard way is to emit Loading if it's a blocking operation.
    // Exporting might take time.
    // Let's emit ClientsLoading just to be safe, or handle it in UI listener.
    // UI logic in ClientsScreen seems to handle overlays or snackbars.
    // Let's NOT emit global ClientsLoading if we want to avoid replacing the list.
    // Actually, `ClientCard` download logic used `ClientPdfDownloaded` state which is a bit weird if it replaces state.
    // Ideally we should use `Action` stream or similar (Side Effects).
    // But `ClientsLoaded` has `downloadedPdfPath`. We can add `exportedFilePath`.
    // Or just emit `ClientsState` is Equatable.

    // Let's inspect `_onDownloadClientPdf`.
    // It emits `ClientsLoaded.copyWith(downloadedPdfPath: path)`.
    // This triggers listener in UI to open file.

    // I will do similarly.
    // Wait, Export is global action, likely initiated from FAB or AppBar.

    final result = await exportClients!(event.filter);

    result.fold((failure) => emit(ClientsError(failure.message)), (path) {
      if (state is ClientsLoaded) {
        final loadedState = state as ClientsLoaded;
        emit(loadedState.copyWith(exportedFilePath: path));
      } else {
        // If not in standard loaded state, maybe dedicated state
        emit(ClientExported(path));
      }
    });
  }

  Future<void> _onAddClientComment(
    AddClientCommentEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (addComment == null) return;

    // We might want to show loading specifically for comments section
    // But for now, let's just optimistically add it or reload?
    // Reloading is safer.

    // We can emit a "AddingComment" state if we want UI feedback,
    // but since the UI is tabbed, a full screen loader (ClientsLoading) might be distracting.
    // However, let's stick to standard pattern for now:

    // emit(ClientsLoading()); // This would hide the tabs content if not handled carefully in UI
    // Ideally, we shouldn't emit ClientsLoading if we are inside a tab, unless the UI handles it gracefully.
    // Let's rely on SnackBar feedback/optimistic update or just simple reload.

    final result = await addComment!(
      event.clientId,
      event.comment,
      attachments: event.attachments,
      mentionIds: event.mentionIds,
    );

    result.fold((failure) => emit(ClientsError(failure.message)), (newComment) {
      // Reload comments to show the new one
      add(LoadClientComments(event.clientId, refresh: true));
      // Also reload timeline if we want
      add(LoadClientTimeline(event.clientId));
    });
  }

  Future<void> _onLoadClientTimeline(
    LoadClientTimeline event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientTimeline == null) return;
    emit(ClientsLoading()); // Or dedicated state

    final result = await getClientTimeline!(event.clientId);

    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (events) => emit(ClientTimelineLoaded(events)),
    );
  }

  Future<void> _onLoadClientComments(
    LoadClientComments event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientComments == null) return;

    if (event.refresh) {
      _commentsPage = 1;
      emit(
        ClientsLoading(),
      ); // Consider separate loading state for tabs if needed
    }

    final result = await getClientComments!(
      clientId: event.clientId,
      page: _commentsPage,
      perPage: _commentsPageSize,
    );

    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientCommentsLoaded(
          paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreClientComments(
    LoadMoreClientComments event,
    Emitter<ClientsState> emit,
  ) async {
    if (state is! ClientCommentsLoaded) return;
    if (getClientComments == null) return;

    final currentState = state as ClientCommentsLoaded;
    if (currentState.hasReachedMax) return;

    _commentsPage++;

    final result = await getClientComments!(
      clientId: event.clientId,
      page: _commentsPage,
      perPage: _commentsPageSize,
    );

    result.fold((failure) => _commentsPage--, (paginatedList) {
      emit(
        currentState.copyWith(
          comments: List.of(currentState.comments)..addAll(paginatedList.items),
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
          page: paginatedList.currentPage,
        ),
      );
    });
  }

  Future<void> _onDownloadClientPdf(
    DownloadClientPdfEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (downloadClientPdf == null) return;

    final result = await downloadClientPdf!(event.clientId);

    result.fold((failure) => emit(ClientsError(failure.message)), (path) {
      if (state is ClientsLoaded) {
        final loadedState = state as ClientsLoaded;
        emit(loadedState.copyWith(downloadedPdfPath: path));
      } else {
        // Emit a dedicated state if not in loaded state, or handle generically
        emit(ClientPdfDownloaded(path));
      }
    });
  }

  Future<void> _onSaveFilter(
    SaveFilterEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (saveFilter == null) return;
    emit(ClientsLoading());

    final result = await saveFilter!(event.filter);

    result.fold((failure) => emit(ClientsError(failure.message)), (_) {
      emit(const ClientsError('تم حفظ الفلتر بنجاح'));
      add(LoadSavedFilters());
      add(const LoadClients());
    });
  }

  Future<void> _onLoadSavedFilters(
    LoadSavedFilters event,
    Emitter<ClientsState> emit,
  ) async {
    if (getSavedFilters == null) return;
    final result = await getSavedFilters!();
    result.fold((failure) => null, (filters) {
      _savedFilters = filters;
      if (state is ClientsLoaded) {
        emit((state as ClientsLoaded).copyWith(savedFilters: filters));
      }
    });
  }

  Future<void> _onDeleteSavedFilter(
    DeleteSavedFilterEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (deleteSavedFilter == null) return;
    final result = await deleteSavedFilter!(event.filterId);
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (_) => add(LoadSavedFilters()),
    );
  }

  Future<void> _onLoadClients(
    LoadClients event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsLoading());
    _currentPage = 1;
    final result = await getClients(
      filter: event.filter,
      page: _currentPage,
      limit: _pageSize,
    );
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientsLoaded(
          paginatedList.items,
          totalClients: paginatedList.total,
          hasReachedMax: paginatedList.items.length < _pageSize,
          savedFilters: _savedFilters,
        ),
      ),
    );
  }

  Future<void> _onRefreshClients(
    RefreshClients event,
    Emitter<ClientsState> emit,
  ) async {
    final result = await getClients();
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientsLoaded(
          paginatedList.items,
          totalClients: paginatedList.total,
          savedFilters: _savedFilters,
        ),
      ),
    );
  }

  Future<void> _onSearchClients(
    SearchClients event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsLoading());
    final result = await getClients(
      filter: ClientFilter(searchQuery: event.query),
      page: 1,
      limit: _pageSize,
    );
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientsLoaded(
          paginatedList.items,
          totalClients: paginatedList.total,
          savedFilters: _savedFilters,
        ),
      ),
    );
  }

  Future<void> _onLoadClientStats(
    LoadClientStats event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientStats == null) return;
    emit(ClientsStatsLoading());
    final result = await getClientStats!();
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (stats) => emit(ClientsStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadClientKPIs(
    LoadClientKPIs event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientKPIs == null) return;
    emit(ClientsStatsLoading());
    final result = await getClientKPIs!();
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (kpis) => emit(ClientsKPIsLoaded(kpis)),
    );
  }

  Future<void> _onAddClient(
    AddClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (addClient == null) return;
    emit(ClientsLoading());
    final result = await addClient!(event.client);
    result.fold((failure) => emit(ClientsError(failure.message)), (client) {
      add(const LoadClients());
    });
  }

  Future<void> _onUpdateClient(
    UpdateClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (updateClient == null) return;
    emit(ClientsLoading());
    final result = await updateClient!(event.client);
    result.fold((failure) => emit(ClientsError(failure.message)), (client) {
      add(const LoadClients());
    });
  }

  Future<void> _onLoadMoreClients(
    LoadMoreClients event,
    Emitter<ClientsState> emit,
  ) async {
    if (state is! ClientsLoaded) return;
    final currentState = state as ClientsLoaded;
    if (currentState.hasReachedMax || currentState.isPaginationLoading) return;

    emit(currentState.copyWith(isPaginationLoading: true));

    _currentPage++;
    final result = await getClients(page: _currentPage, limit: _pageSize);

    result.fold(
      (failure) => emit(currentState.copyWith(isPaginationLoading: false)),
      (paginatedList) {
        if (paginatedList.items.isEmpty) {
          emit(
            currentState.copyWith(
              hasReachedMax: true,
              isPaginationLoading: false,
              totalClients: paginatedList.total,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              clients: List.of(currentState.clients)
                ..addAll(paginatedList.items),
              hasReachedMax: paginatedList.items.length < _pageSize,
              isPaginationLoading: false,
              totalClients: paginatedList.total,
            ),
          );
        }
      },
    );
  }

  Future<void> _onUpdateBulkStatus(
    UpdateClientsBulkStatus event,
    Emitter<ClientsState> emit,
  ) async {
    if (updateBulkStatus == null) return;
    final result = await updateBulkStatus!(event.clientIds, event.statusId);
    result.fold((failure) => null, (_) => add(const LoadClients()));
  }

  Future<void> _onAssignBulk(
    AssignClientsBulk event,
    Emitter<ClientsState> emit,
  ) async {
    if (assignBulk == null) return;
    final result = await assignBulk!(event.clientIds, event.userId);
    result.fold((failure) => null, (_) => add(const LoadClients()));
  }

  Future<void> _onDeleteBulk(
    DeleteClientsBulk event,
    Emitter<ClientsState> emit,
  ) async {
    if (deleteBulk == null) return;
    final result = await deleteBulk!(event.clientIds);
    result.fold((failure) => null, (_) => add(const LoadClients()));
  }

  Future<void> _onDeleteClient(
    DeleteClientEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (deleteClient == null) return;
    emit(ClientsLoading());
    final result = await deleteClient!(event.clientId);
    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (_) => add(const LoadClients()),
    );
  }

  Future<void> _onUploadClientFile(
    UploadClientFileEvent event,
    Emitter<ClientsState> emit,
  ) async {
    if (uploadFile == null) return;
    emit(ClientsLoading());

    final result = await uploadFile!(event.clientId, event.file, event.type);

    result.fold(
      (failure) {
        emit(ClientsError(failure.message));
      },
      (file) {
        add(const LoadClients());
        add(LoadClientFiles(event.clientId));
      },
    );
  }

  Future<void> _onLoadClientInvoices(
    LoadClientInvoices event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientInvoices == null) return;

    if (event.refresh) {
      _invoicesPage = 1;
      emit(ClientsLoading());
    }

    final result = await getClientInvoices!(
      clientId: event.clientId,
      page: _invoicesPage,
      perPage: _invoicesPageSize,
    );

    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientInvoicesLoaded(
          paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreClientInvoices(
    LoadMoreClientInvoices event,
    Emitter<ClientsState> emit,
  ) async {
    if (state is! ClientInvoicesLoaded) return;
    if (getClientInvoices == null) return;

    final currentState = state as ClientInvoicesLoaded;
    if (currentState.hasReachedMax) return;

    _invoicesPage++;

    final result = await getClientInvoices!(
      clientId: event.clientId,
      page: _invoicesPage,
      perPage: _invoicesPageSize,
    );

    result.fold((failure) => _invoicesPage--, (paginatedList) {
      emit(
        currentState.copyWith(
          invoices: List.of(currentState.invoices)..addAll(paginatedList.items),
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
          page: paginatedList.currentPage,
        ),
      );
    });
  }

  Future<void> _onLoadClientAppointments(
    LoadClientAppointments event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientAppointments == null) return;

    if (event.refresh) {
      _appointmentsPage = 1;
      emit(ClientsLoading());
    }

    final result = await getClientAppointments!(
      clientId: event.clientId,
      page: _appointmentsPage,
      perPage: _appointmentsPageSize,
    );

    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (paginatedList) => emit(
        ClientAppointmentsLoaded(
          paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreClientAppointments(
    LoadMoreClientAppointments event,
    Emitter<ClientsState> emit,
  ) async {
    if (state is! ClientAppointmentsLoaded) return;
    if (getClientAppointments == null) return;

    final currentState = state as ClientAppointmentsLoaded;
    if (currentState.hasReachedMax) return;

    _appointmentsPage++;

    final result = await getClientAppointments!(
      clientId: event.clientId,
      page: _appointmentsPage,
      perPage: _appointmentsPageSize,
    );

    result.fold((failure) => _appointmentsPage--, (paginatedList) {
      emit(
        currentState.copyWith(
          appointments: List.of(currentState.appointments)
            ..addAll(paginatedList.items),
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
          page: paginatedList.currentPage,
        ),
      );
    });
  }

  Future<void> _onLoadClientFiles(
    LoadClientFiles event,
    Emitter<ClientsState> emit,
  ) async {
    if (getClientFiles == null) return;
    emit(ClientsLoading());

    final result = await getClientFiles!(event.clientId);

    result.fold(
      (failure) => emit(ClientsError(failure.message)),
      (files) => emit(ClientFilesLoaded(files)),
    );
  }
}
