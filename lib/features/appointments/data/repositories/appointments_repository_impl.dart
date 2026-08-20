import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource remoteDataSource;

  AppointmentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedList<Appointment>>> getAppointments({
    int page = 1,
    int? limit,
    String? status,
    String? type,
    int? clientId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final result = await remoteDataSource.getAppointments(
        page: page,
        limit: limit,
        status: status,
        type: type,
        clientId: clientId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentDetails(int id) async {
    try {
      final result = await remoteDataSource.getAppointmentDetails(id);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createAppointment(data);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateAppointment(id, data);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAppointment(int id) async {
    try {
      await remoteDataSource.deleteAppointment(id);
      return const Right(unit);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> changeAppointmentStatus(
    int id,
    String status,
  ) async {
    try {
      final result = await remoteDataSource.changeAppointmentStatus(id, status);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
