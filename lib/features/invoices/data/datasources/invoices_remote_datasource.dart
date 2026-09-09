import '../../../../core/common/models/paginated_list.dart';
import '../models/invoice_model.dart';

abstract class InvoicesRemoteDataSource {
  Future<PaginatedList<InvoiceModel>> getInvoices({
    int page = 1,
    int? limit,
    String? status,
    int? clientId,
    int? userId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    List<int>? tagIds,
  });

  Future<InvoiceModel> getInvoiceDetails(int id);

  Future<InvoiceModel> createInvoice(Map<String, dynamic> data);

  Future<InvoiceModel> updateInvoice(int id, Map<String, dynamic> data);

  Future<void> deleteInvoice(int id);

  Future<InvoiceModel> changeInvoiceStatus(int id, String status);

  Future<InvoiceModel> assignInvoiceTags(int id, List<int> tagIds);

  Future<void> sendInvoice(int id, List<String> channels);

  Future<void> downloadInvoicePdf(int id, String savePath);
}
