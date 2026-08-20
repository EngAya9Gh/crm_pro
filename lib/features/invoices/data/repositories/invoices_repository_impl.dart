import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../datasources/invoices_remote_datasource.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  final InvoicesRemoteDataSource remoteDataSource;

  InvoicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedList<Invoice>>> getInvoices({
    int page = 1,
    int? limit,
    String? status,
    int? clientId,
    int? userId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final result = await remoteDataSource.getInvoices(
        page: page,
        limit: limit,
        status: status,
        clientId: clientId,
        userId: userId,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getInvoiceDetails(int id) async {
    try {
      final result = await remoteDataSource.getInvoiceDetails(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> createInvoice(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createInvoice(data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoice(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateInvoice(id, data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvoice(int id) async {
    try {
      await remoteDataSource.deleteInvoice(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> changeInvoiceStatus(
    int id,
    String status,
  ) async {
    try {
      final result = await remoteDataSource.changeInvoiceStatus(id, status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendInvoice(
    int id,
    List<String> channels,
  ) async {
    try {
      await remoteDataSource.sendInvoice(id, channels);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> downloadInvoicePdf(
    int id,
    String savePath,
  ) async {
    try {
      await remoteDataSource.downloadInvoicePdf(id, savePath);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
