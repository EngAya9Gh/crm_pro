import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';
import '../../../clients/domain/entities/client_brief.dart';
import '../../../../features/settings/domain/entities/product.dart';

enum InvoicesStatus { initial, loading, success, failure }

enum InvoiceOperationStatus { initial, loading, success, failure }

class InvoicesState extends Equatable {
  final InvoicesStatus status;
  final List<Invoice> invoices;
  final bool hasReachedMax;
  final int page;
  final int total;
  final int lastPage;
  final String errorMessage;

  final InvoicesStatus detailStatus;
  final Invoice? invoiceDetail;

  final InvoiceOperationStatus operationStatus;
  final String operationMessage;

  final List<ClientBrief> clientList;
  final List<Product> productList;
  final bool isClientsLoading;
  final bool isProductsLoading;

  const InvoicesState({
    this.status = InvoicesStatus.initial,
    this.invoices = const [],
    this.hasReachedMax = false,
    this.page = 1,
    this.total = 0,
    this.lastPage = 1,
    this.errorMessage = '',
    this.detailStatus = InvoicesStatus.initial,
    this.invoiceDetail,
    this.operationStatus = InvoiceOperationStatus.initial,
    this.operationMessage = '',
    this.clientList = const [],
    this.productList = const [],
    this.isClientsLoading = false,
    this.isProductsLoading = false,
  });

  InvoicesState copyWith({
    InvoicesStatus? status,
    List<Invoice>? invoices,
    bool? hasReachedMax,
    int? page,
    int? total,
    int? lastPage,
    String? errorMessage,
    InvoicesStatus? detailStatus,
    Invoice? invoiceDetail,
    InvoiceOperationStatus? operationStatus,
    String? operationMessage,
    List<ClientBrief>? clientList,
    List<Product>? productList,
    bool? isClientsLoading,
    bool? isProductsLoading,
  }) {
    return InvoicesState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      total: total ?? this.total,
      lastPage: lastPage ?? this.lastPage,
      errorMessage: errorMessage ?? this.errorMessage,
      detailStatus: detailStatus ?? this.detailStatus,
      invoiceDetail: invoiceDetail ?? this.invoiceDetail,
      operationStatus: operationStatus ?? this.operationStatus,
      operationMessage: operationMessage ?? this.operationMessage,
      clientList: clientList ?? this.clientList,
      productList: productList ?? this.productList,
      isClientsLoading: isClientsLoading ?? this.isClientsLoading,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    invoices,
    hasReachedMax,
    page,
    total,
    lastPage,
    errorMessage,
    detailStatus,
    invoiceDetail,
    operationStatus,
    operationMessage,
    clientList,
    productList,
    isClientsLoading,
    isProductsLoading,
  ];
}
