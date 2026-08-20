import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_item.dart';
import '../repositories/stock_repository.dart';

class SyncProductsUseCase {
  final StockRepository repository;

  SyncProductsUseCase(this.repository);

  Future<Either<Failure, List<StockItem>>> call() {
    return repository.syncProducts();
  }
}
