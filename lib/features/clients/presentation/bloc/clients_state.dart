import 'package:equatable/equatable.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_file.dart';
import 'package:crm_wakeel/features/invoices/domain/entities/invoice.dart';
import 'package:crm_wakeel/features/appointments/domain/entities/appointment.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/saved_filter.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/client_stats.dart';
import '../../domain/entities/client_kpi.dart';
import '../../domain/entities/timeline_event.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object?> get props => [];
}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<Client> clients;
  final int totalClients;
  final bool hasReachedMax;

  final bool isPaginationLoading;
  final String? downloadedPdfPath;
  final String? exportedFilePath; // Added
  final List<SavedFilter> savedFilters;

  const ClientsLoaded(
    this.clients, {
    this.totalClients = 0,
    this.hasReachedMax = false,
    this.isPaginationLoading = false,
    this.downloadedPdfPath,
    this.exportedFilePath, // Added
    this.savedFilters = const [],
  });

  @override
  List<Object?> get props => [
    clients,
    totalClients,
    hasReachedMax,
    isPaginationLoading,
    downloadedPdfPath,
    exportedFilePath, // Added
    savedFilters,
  ];

  ClientsLoaded copyWith({
    List<Client>? clients,
    int? totalClients,
    bool? hasReachedMax,
    bool? isPaginationLoading,
    String? downloadedPdfPath,
    String? exportedFilePath, // Added
    List<SavedFilter>? savedFilters,
  }) {
    return ClientsLoaded(
      clients ?? this.clients,
      totalClients: totalClients ?? this.totalClients,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      downloadedPdfPath: downloadedPdfPath,
      exportedFilePath: exportedFilePath, // Added
      savedFilters: savedFilters ?? this.savedFilters,
    );
  }
}

class ClientsError extends ClientsState {
  final String message;
  const ClientsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientOperationSuccess extends ClientsState {
  final String message;
  const ClientOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientsStatsLoading extends ClientsState {}

class ClientsStatsLoaded extends ClientsState {
  final ClientStats stats;
  const ClientsStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ClientsKPIsLoaded extends ClientsState {
  final ClientKPI kpis;
  const ClientsKPIsLoaded(this.kpis);

  @override
  List<Object?> get props => [kpis];
}

class ClientPdfDownloaded extends ClientsState {
  final String path;
  const ClientPdfDownloaded(this.path);
  @override
  List<Object?> get props => [path];
}

class ClientCommentsLoaded extends ClientsState {
  final List<Comment> comments;
  final bool hasReachedMax;
  final int page;

  const ClientCommentsLoaded(
    this.comments, {
    this.hasReachedMax = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [comments, hasReachedMax, page];

  ClientCommentsLoaded copyWith({
    List<Comment>? comments,
    bool? hasReachedMax,
    int? page,
  }) {
    return ClientCommentsLoaded(
      comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }
}

class ClientTimelineLoaded extends ClientsState {
  final List<TimelineEvent> events;

  const ClientTimelineLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class ClientExported extends ClientsState {
  final String path;
  const ClientExported(this.path);
  @override
  List<Object?> get props => [path];
}

class ClientInvoicesLoaded extends ClientsState {
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

class ClientAppointmentsLoaded extends ClientsState {
  final List<Appointment> appointments;
  final bool hasReachedMax;
  final int page;

  const ClientAppointmentsLoaded(
    this.appointments, {
    this.hasReachedMax = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [appointments, hasReachedMax, page];

  ClientAppointmentsLoaded copyWith({
    List<Appointment>? appointments,
    bool? hasReachedMax,
    int? page,
  }) {
    return ClientAppointmentsLoaded(
      appointments ?? this.appointments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }
}

class ClientFilesLoaded extends ClientsState {
  final List<ClientFile> files;
  const ClientFilesLoaded(this.files);
  @override
  List<Object?> get props => [files];
}
