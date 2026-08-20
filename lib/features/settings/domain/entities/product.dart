import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final double price;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, price, isActive];
}
