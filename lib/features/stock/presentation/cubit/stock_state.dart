part of 'stock_cubit.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockScanLoading extends StockState {}

class StockScanSuccess extends StockState {
  final StockItem stockItem;

  const StockScanSuccess({required this.stockItem});

  @override
  List<Object> get props => [stockItem];
}

class StockScanError extends StockState {
  final String message;

  const StockScanError({required this.message});

  @override
  List<Object> get props => [message];
}

class StockValidationLoading extends StockState {}

class StockValidationSuccess extends StockState {
  final StockValidationResult result;

  const StockValidationSuccess({required this.result});

  @override
  List<Object> get props => [result];
}

class StockValidationError extends StockState {
  final String message;

  const StockValidationError({required this.message});

  @override
  List<Object> get props => [message];
}

class StockSyncLoading extends StockState {}

class StockSyncSuccess extends StockState {
  final List<StockItem> products;

  const StockSyncSuccess({required this.products});

  @override
  List<Object> get props => [products];
}

class StockSyncError extends StockState {
  final String message;

  const StockSyncError({required this.message});

  @override
  List<Object> get props => [message];
}
