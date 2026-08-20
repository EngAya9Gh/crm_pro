import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_validation_result.dart';
import '../repositories/stock_repository.dart';

class ValidateStockParams {
  final List<Map<String, dynamic>> items;

  ValidateStockParams({required this.items});
}

class ValidateStockUseCase {
  // Removed generic UseCase inheritance
  final StockRepository stockRepository;

  ValidateStockUseCase(this.stockRepository);

  Future<Either<Failure, StockValidationResult>> call(
    ValidateStockParams params,
  ) async {
    return await stockRepository.validateStock(items: params.items);
  }
}
