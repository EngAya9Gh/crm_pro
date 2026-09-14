import 'package:equatable/equatable.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/saved_filter.dart';
import '../../domain/entities/comment.dart'; // Added

abstract class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadClients extends ClientsEvent {
  final ClientFilter? filter;
  const LoadClients({this.filter});

  @override
  List<Object?> get props => [filter];
}

class SearchClients extends ClientsEvent {
  final String query;
  const SearchClients(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshClients extends ClientsEvent {}

class LoadClientStats extends ClientsEvent {}

class LoadClientKPIs extends ClientsEvent {}

class AddClientEvent extends ClientsEvent {
  final Client client;
  const AddClientEvent(this.client);

  @override
  List<Object?> get props => [client];
}

class UpdateClientEvent extends ClientsEvent {
  final Client client;
  const UpdateClientEvent(this.client);

  @override
  List<Object?> get props => [client];
}

class LoadMoreClients extends ClientsEvent {}

class UpdateClientsBulkStatus extends ClientsEvent {
  final List<String> clientIds;
  final int statusId;
  const UpdateClientsBulkStatus(this.clientIds, this.statusId);

  @override
  List<Object?> get props => [clientIds, statusId];
}

class AssignClientsBulk extends ClientsEvent {
  final List<String> clientIds;
  final String userId;
  const AssignClientsBulk(this.clientIds, this.userId);

  @override
  List<Object?> get props => [clientIds, userId];
}

class DeleteClientsBulk extends ClientsEvent {
  final List<String> clientIds;
  const DeleteClientsBulk(this.clientIds);

  @override
  List<Object?> get props => [clientIds];
}

class DeleteClientEvent extends ClientsEvent {
  final String clientId;
  const DeleteClientEvent(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

class UploadClientFileEvent extends ClientsEvent {
  final String clientId;
  final dynamic file;
  final String type; // Send string to be flexible or FileType

  const UploadClientFileEvent(this.clientId, this.file, this.type);

  @override
  List<Object?> get props => [clientId, file, type];
}

class DownloadClientPdfEvent extends ClientsEvent {
  final String clientId;

  const DownloadClientPdfEvent(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

class SaveFilterEvent extends ClientsEvent {
  final SavedFilter filter;
  const SaveFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class LoadSavedFilters extends ClientsEvent {}

class DeleteSavedFilterEvent extends ClientsEvent {
  final String filterId;
  const DeleteSavedFilterEvent(this.filterId);

  @override
  List<Object?> get props => [filterId];
}

class LoadClientComments extends ClientsEvent {
  final String clientId;
  final bool
  refresh; // for pull to refresh or initial load vs load more if needed

  const LoadClientComments(this.clientId, {this.refresh = false});

  @override
  List<Object?> get props => [clientId, refresh];
}

class LoadMoreClientComments extends ClientsEvent {
  final String clientId;

  const LoadMoreClientComments(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

class LoadClientTimeline extends ClientsEvent {
  final String clientId;

  const LoadClientTimeline(this.clientId);

  @override
  List<Object?> get props => [clientId];
}

class AddClientCommentEvent extends ClientsEvent {
  final String clientId;
  final Comment comment;
  final List<dynamic>? attachments;
  final List<String>? mentionIds;

  const AddClientCommentEvent({
    required this.clientId,
    required this.comment,
    this.attachments,
    this.mentionIds,
  });

  @override
  List<Object?> get props => [clientId, comment, attachments, mentionIds];
}

class ExportClientsEvent extends ClientsEvent {
  final ClientFilter? filter;
  final String format; // 'csv', 'excel' or 'pdf'

  const ExportClientsEvent({this.filter, this.format = 'csv'});

  @override
  List<Object?> get props => [filter, format];
}

class LoadClientInvoices extends ClientsEvent {
  final String clientId;
  final bool refresh;
  const LoadClientInvoices(this.clientId, {this.refresh = false});
  @override
  List<Object?> get props => [clientId, refresh];
}

class LoadMoreClientInvoices extends ClientsEvent {
  final String clientId;
  const LoadMoreClientInvoices(this.clientId);
  @override
  List<Object?> get props => [clientId];
}

class LoadClientAppointments extends ClientsEvent {
  final String clientId;
  final bool refresh;
  const LoadClientAppointments(this.clientId, {this.refresh = false});
  @override
  List<Object?> get props => [clientId, refresh];
}

class LoadMoreClientAppointments extends ClientsEvent {
  final String clientId;
  const LoadMoreClientAppointments(this.clientId);
  @override
  List<Object?> get props => [clientId];
}

class LoadClientFiles extends ClientsEvent {
  final String clientId;
  const LoadClientFiles(this.clientId);
  @override
  List<Object?> get props => [clientId];
}
