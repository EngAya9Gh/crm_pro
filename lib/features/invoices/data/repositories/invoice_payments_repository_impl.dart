import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/invoice_payment.dart';
import '../../domain/repositories/invoice_payments_repository.dart';
import '../datasources/invoice_payments_remote_datasource.dart';

class InvoicePaymentsRepositoryImpl implements InvoicePaymentsRepository {
  final InvoicePaymentsRemoteDataSource remoteDataSource;

  InvoicePaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InvoicePayment>>> getPayments(
    int invoiceId,
  ) async {
    try {
      final payments = await remoteDataSource.getPayments(invoiceId);
      return Right(payments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoicePayment>> addPayment(
    int invoiceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final payment = await remoteDataSource.addPayment(invoiceId, data);
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoicePayment>> updatePayment(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final payment = await remoteDataSource.updatePayment(
        invoiceId,
        paymentId,
        data,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(
    int invoiceId,
    int paymentId,
  ) async {
    try {
      await remoteDataSource.deletePayment(invoiceId, paymentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
