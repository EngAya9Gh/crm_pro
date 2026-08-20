import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/stock_item_model.dart';
import '../models/stock_validation_result_model.dart';

abstract class StockRemoteDataSource {
  Future<StockItemModel> scanProduct(String sku);
  Future<StockValidationResultModel> validateStock(
    List<Map<String, dynamic>> items,
  );
  Future<List<StockItemModel>> syncProducts();
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final ApiClient apiClient;

  StockRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StockItemModel> scanProduct(String sku) async {
    final response = await apiClient.get<StockItemModel>(
      EndPoints.stockScan,
      queryParameters: {'sku': sku},
      fromJson: (json) => StockItemModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<StockValidationResultModel> validateStock(
    List<Map<String, dynamic>> items,
  ) async {
    final response = await apiClient.post<StockValidationResultModel>(
      EndPoints.stockValidate,
      data: {'items': items},
      fromJson: (json) =>
          StockValidationResultModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<StockItemModel>> syncProducts() async {
    final response = await apiClient.get<List<StockItemModel>>(
      EndPoints.productsSync,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => StockItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }
}
