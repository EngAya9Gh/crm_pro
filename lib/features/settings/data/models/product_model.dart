import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      isActive: json['is_active'] ?? false,
    );
  }
}
