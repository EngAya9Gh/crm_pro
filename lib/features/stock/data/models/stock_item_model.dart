import '../../domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.stockErp,
    required super.stockLocal,
    required super.price,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      stockErp: json['stock_erp'] ?? 0,
      stockLocal: json['stock_local'] ?? 0,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'stock_erp': stockErp,
      'stock_local': stockLocal,
      'price': price,
    };
  }
}
