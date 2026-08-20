import '../../domain/entities/stock_validation_result.dart';

class StockValidationResultModel extends StockValidationResult {
  const StockValidationResultModel({
    required super.success,
    required super.message,
    super.unavailableItems,
  });

  factory StockValidationResultModel.fromJson(Map<String, dynamic> json) {
    return StockValidationResultModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      unavailableItems: json['unavailable_items'] != null
          ? (json['unavailable_items'] as List)
                .map((e) => UnavailableItemModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class UnavailableItemModel extends UnavailableItem {
  const UnavailableItemModel({
    required super.sku,
    required super.requested,
    required super.available,
    required super.message,
  });

  factory UnavailableItemModel.fromJson(Map<String, dynamic> json) {
    return UnavailableItemModel(
      sku: json['sku'] ?? '',
      requested: json['requested'] ?? 0,
      available: json['available'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
