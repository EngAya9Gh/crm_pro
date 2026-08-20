import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

class ScanProductUseCase {
  // Removed generic UseCase inheritance
  final StockRepository stockRepository;

  ScanProductUseCase(this.stockRepository);

  Future<Either<Failure, StockItem>> call(String sku) async {
    return await stockRepository.scanProduct(sku);
  }
}
