import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_item.dart';
import '../entities/stock_validation_result.dart';

abstract class StockRepository {
  Future<Either<Failure, StockItem>> scanProduct(String sku);

  Future<Either<Failure, StockValidationResult>> validateStock({
    required List<Map<String, dynamic>> items,
  });

  Future<Either<Failure, List<StockItem>>> syncProducts();
}
