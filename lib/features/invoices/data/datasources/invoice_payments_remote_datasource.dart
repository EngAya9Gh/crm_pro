import '../../../../core/services/network/api_client.dart';
import '../models/invoice_payment_model.dart';
import '../../../../core/utils/end_points.dart';

abstract class InvoicePaymentsRemoteDataSource {
  Future<List<InvoicePaymentModel>> getPayments(int invoiceId);
  Future<InvoicePaymentModel> addPayment(
    int invoiceId,
    Map<String, dynamic> data,
  );
  Future<InvoicePaymentModel> updatePayment(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  );
  Future<void> deletePayment(int invoiceId, int paymentId);
}

class InvoicePaymentsRemoteDataSourceImpl
    implements InvoicePaymentsRemoteDataSource {
  final ApiClient apiClient;

  InvoicePaymentsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<InvoicePaymentModel>> getPayments(int invoiceId) async {
    final response = await apiClient.get(
      '${EndPoints.invoices}/$invoiceId/payments',
      fromJson: (json) =>
          (json as List).map((e) => InvoicePaymentModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<InvoicePaymentModel> addPayment(
    int invoiceId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '${EndPoints.invoices}/$invoiceId/payments',
      data: data,
      fromJson: (json) =>
          InvoicePaymentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<InvoicePaymentModel> updatePayment(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '${EndPoints.invoices}/$invoiceId/payments/$paymentId',
      data: data,
      fromJson: (json) =>
          InvoicePaymentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deletePayment(int invoiceId, int paymentId) async {
    await apiClient.delete(
      '${EndPoints.invoices}/$invoiceId/payments/$paymentId',
      fromJson: (json) => null,
    );
  }
}
