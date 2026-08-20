import 'package:equatable/equatable.dart';

class StockItem extends Equatable {
  final int id;
  final String name;
  final String sku;
  final int stockErp;
  final int stockLocal;
  final double price;

  const StockItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.stockErp,
    required this.stockLocal,
    required this.price,
  });

  @override
  List<Object> get props => [id, name, sku, stockErp, stockLocal, price];
}
