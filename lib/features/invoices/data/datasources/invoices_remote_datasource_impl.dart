import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../models/invoice_model.dart';
import 'invoices_remote_datasource.dart';

class InvoicesRemoteDataSourceImpl implements InvoicesRemoteDataSource {
  final ApiClient apiClient;

  InvoicesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedList<InvoiceModel>> getInvoices({
    int page = 1,
    int? limit,
    String? status,
    int? clientId,
    int? userId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (page > 1) queryParams['page'] = page;
    if (limit != null && limit != 15) queryParams['per_page'] = limit;

    if (status != null) queryParams['status'] = status;
    if (clientId != null) queryParams['client_id'] = clientId;
    if (userId != null) queryParams['user_id'] = userId;
    if (search != null) queryParams['search'] = search;
    if (dateFrom != null) {
      queryParams['due_date_from'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      queryParams['due_date_to'] = dateTo.toIso8601String();
    }

    final response = await apiClient.get(
      EndPoints.invoices,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => InvoiceModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 15,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<InvoiceModel> getInvoiceDetails(int id) async {
    final response = await apiClient.get(
      EndPoints.invoice(id.toString()),
      fromJson: (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.invoices,
      data: data,
      fromJson: (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<InvoiceModel> updateInvoice(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.invoice(id.toString()),
      data: data,
      fromJson: (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteInvoice(int id) async {
    await apiClient.delete(
      EndPoints.invoice(id.toString()),
      fromJson: (json) => null,
    );
  }

  @override
  Future<InvoiceModel> changeInvoiceStatus(int id, String status) async {
    final response = await apiClient.patch(
      EndPoints.invoiceStatus(id.toString()),
      data: {'status': status},
      fromJson: (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> sendInvoice(int id, List<String> channels) async {
    await apiClient.post(
      EndPoints.invoiceSend(id.toString()),
      data: {'channels': channels},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> downloadInvoicePdf(int id, String savePath) async {
    await apiClient.download(EndPoints.invoicePdf(id.toString()), savePath);
  }
}
