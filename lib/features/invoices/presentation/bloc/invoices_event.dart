import 'package:equatable/equatable.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoicesEvent {
  final int page;
  final String? status;
  final int? clientId;
  final int? userId;
  final String? search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<int>? tagIds;
  final bool isRefresh;

  const LoadInvoices({
    this.page = 1,
    this.status,
    this.clientId,
    this.userId,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.tagIds,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    status,
    clientId,
    userId,
    search,
    dateFrom,
    dateTo,
    tagIds,
    isRefresh,
  ];
}

class LoadMoreInvoices extends InvoicesEvent {}

class GetInvoiceDetailsEvent extends InvoicesEvent {
  final int id;
  const GetInvoiceDetailsEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateInvoiceEvent extends InvoicesEvent {
  final Map<String, dynamic> data;
  const CreateInvoiceEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateInvoiceEvent extends InvoicesEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateInvoiceEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteInvoiceEvent extends InvoicesEvent {
  final int id;
  const DeleteInvoiceEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeInvoiceStatusEvent extends InvoicesEvent {
  final int id;
  final String status;
  const ChangeInvoiceStatusEvent(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class SendInvoiceEvent extends InvoicesEvent {
  final int id;
  final List<String> channels;
  const SendInvoiceEvent(this.id, this.channels);
  @override
  List<Object?> get props => [id, channels];
}

class DownloadInvoicePdfEvent extends InvoicesEvent {
  final int id;
  final String savePath;
  const DownloadInvoicePdfEvent(this.id, this.savePath);
  @override
  List<Object?> get props => [id, savePath];
}

class GetInvoiceClientsEvent extends InvoicesEvent {
  final String? search;
  const GetInvoiceClientsEvent({this.search});
  @override
  List<Object?> get props => [search];
}

class GetInvoiceProductsEvent extends InvoicesEvent {}

class AssignInvoiceTagsEvent extends InvoicesEvent {
  final int id;
  final List<int> tagIds;
  const AssignInvoiceTagsEvent(this.id, this.tagIds);
  @override
  List<Object?> get props => [id, tagIds];
}
