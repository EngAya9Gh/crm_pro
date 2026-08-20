import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_validation_result.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_data_source.dart';
import '../datasources/stock_remote_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;
  final StockLocalDataSource localDataSource;

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, StockItem>> scanProduct(String sku) async {
    try {
      final remoteStock = await remoteDataSource.scanProduct(sku);
      return Right(remoteStock);
    } on NetworkException {
      try {
        final localStock = await localDataSource.getProductBySku(sku);
        return Right(localStock);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } on ServerException catch (e) {
      try {
        final localStock = await localDataSource.getProductBySku(sku);
        return Right(localStock);
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockValidationResult>> validateStock({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final validationResult = await remoteDataSource.validateStock(items);
      return Right(validationResult);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> syncProducts() async {
    try {
      final remoteProducts = await remoteDataSource.syncProducts();
      await localDataSource.cacheProducts(remoteProducts);
      return Right(remoteProducts);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
