import 'package:equatable/equatable.dart';

class StockValidationResult extends Equatable {
  final bool success;
  final String message;
  final List<UnavailableItem> unavailableItems;

  const StockValidationResult({
    required this.success,
    required this.message,
    this.unavailableItems = const [],
  });

  @override
  List<Object> get props => [success, message, unavailableItems];
}

class UnavailableItem extends Equatable {
  final String sku;
  final int requested;
  final int available;
  final String message;

  const UnavailableItem({
    required this.sku,
    required this.requested,
    required this.available,
    required this.message,
  });

  @override
  List<Object> get props => [sku, requested, available, message];
}
