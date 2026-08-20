import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/api_exception.dart';
import '../models/stock_item_model.dart';

abstract class StockLocalDataSource {
  Future<void> cacheProducts(List<StockItemModel> products);
  Future<List<StockItemModel>> getCachedProducts();
  Future<StockItemModel> getProductBySku(String sku);
}

const cachedProductsKey = 'CACHED_PRODUCTS';

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final SharedPreferences sharedPreferences;

  StockLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProducts(List<StockItemModel> products) {
    final List<Map<String, dynamic>> jsonList = products
        .map((item) => item.toJson())
        .toList();
    return sharedPreferences.setString(cachedProductsKey, jsonEncode(jsonList));
  }

  @override
  Future<List<StockItemModel>> getCachedProducts() {
    final jsonString = sharedPreferences.getString(cachedProductsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return Future.value(
        jsonList
            .map(
              (item) => StockItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<StockItemModel> getProductBySku(String sku) async {
    final products = await getCachedProducts();
    try {
      final product = products.firstWhere((element) => element.sku == sku);
      return product;
    } catch (e) {
      throw ServerException(message: 'المنتج غير موجود في النسخة المحلية');
    }
  }
}
