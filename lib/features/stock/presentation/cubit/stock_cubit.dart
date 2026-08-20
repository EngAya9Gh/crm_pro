import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_validation_result.dart';
import '../../domain/usecases/scan_product_usecase.dart';
import '../../domain/usecases/sync_products_usecase.dart';
import '../../domain/usecases/validate_stock_usecase.dart';

part 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final ScanProductUseCase scanProductUseCase;
  final ValidateStockUseCase validateStockUseCase;
  final SyncProductsUseCase syncProductsUseCase;

  StockCubit({
    required this.scanProductUseCase,
    required this.validateStockUseCase,
    required this.syncProductsUseCase,
  }) : super(StockInitial());

  Future<void> scanProduct(String sku) async {
    emit(StockScanLoading());
    final result = await scanProductUseCase(sku);
    result.fold(
      (failure) => emit(
        StockScanError(message: failure.toString()),
      ), // Ideally map failure to message
      (stockItem) => emit(StockScanSuccess(stockItem: stockItem)),
    );
  }

  Future<void> validateStock(List<Map<String, dynamic>> items) async {
    emit(StockValidationLoading());
    final result = await validateStockUseCase(
      ValidateStockParams(items: items),
    );
    result.fold(
      (failure) => emit(StockValidationError(message: failure.toString())),
      (validationResult) =>
          emit(StockValidationSuccess(result: validationResult)),
    );
  }

  Future<void> syncProducts() async {
    emit(StockSyncLoading());
    final result = await syncProductsUseCase();
    result.fold(
      (failure) => emit(StockSyncError(message: failure.toString())),
      (products) => emit(StockSyncSuccess(products: products)),
    );
  }
}
