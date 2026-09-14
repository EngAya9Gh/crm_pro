import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:crm_wakeel/features/clients/data/models/client_model.dart';
import 'package:crm_wakeel/features/clients/data/models/comment_model.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_brief.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_file.dart';
import 'package:crm_wakeel/features/clients/domain/entities/comment.dart';
import 'package:crm_wakeel/features/clients/domain/entities/saved_filter.dart';
import 'package:crm_wakeel/features/clients/domain/entities/timeline_event.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_procedure.dart';
import 'package:crm_wakeel/features/clients/domain/entities/dynamic_field.dart';
import 'package:crm_wakeel/features/clients/data/models/dynamic_field_model.dart';
import 'package:crm_wakeel/features/clients/data/models/client_procedure_model.dart';

import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_stats.dart';
import 'package:crm_wakeel/features/invoices/domain/entities/invoice.dart';
import 'package:crm_wakeel/features/appointments/domain/entities/appointment.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_kpi.dart';

import 'package:crm_wakeel/core/common/models/paginated_list.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  ClientsRepositoryImpl({required this.remoteDataSource});

  // ... (existing code) ...

  @override
  Future<Either<Failure, PaginatedList<Client>>> getClients({
    ClientFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final clients = await remoteDataSource.getClients(
        filter: filter,
        page: page,
        limit: limit,
      );
      return Right(clients);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<ClientBrief>>> getClientsList({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    try {
      final result = await remoteDataSource.getClientsList(
        page: page,
        perPage: perPage,
        search: search,
      );
      // Data Layer returns ClientBriefModel which extends ClientBrief, so it works.
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Client>> getClientDetails(String id) async {
    try {
      final client = await remoteDataSource.getClientDetails(id);
      return Right(client);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Client>> addClient(Client client) async {
    try {
      final clientModel =
          client as ClientModel; // This might need a mapper if types mismatch
      final result = await remoteDataSource.addClient(clientModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient(Client client) async {
    try {
      final clientModel = client as ClientModel;
      final result = await remoteDataSource.updateClient(clientModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changeClientStatus(
    String clientId,
    int statusId,
  ) async {
    try {
      await remoteDataSource.changeClientStatus(clientId, statusId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  @override
  Future<Either<Failure, Comment>> addComment(
    String clientId,
    Comment comment, {
    List<dynamic>? attachments,
    List<String>? mentionIds,
  }) async {
    try {
      final commentModel = CommentModel(
        id: comment.id,
        content: comment.content,
        typeId: comment.typeId,
        outcome: comment.outcome,
        nextFollowUp: comment.nextFollowUp,
        createdAt: comment.createdAt,
        createdBy: comment.createdBy,
        attachments: comment.attachments,
        mentions: comment.mentions,
      );
      final result = await remoteDataSource.addComment(
        clientId,
        commentModel,
        attachments: attachments,
        mentionIds: mentionIds,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<Comment>>> getComments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await remoteDataSource.getComments(
        clientId: clientId,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientFile>> uploadFile(
    String clientId,
    dynamic file,
    String type,
  ) async {
    try {
      final result = await remoteDataSource.uploadFile(clientId, file, type);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TimelineEvent>>> getTimeline(
    String clientId,
  ) async {
    try {
      final events = await remoteDataSource.getTimeline(clientId);
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientStats>> getClientStats() async {
    try {
      // statsMap removed as it was unused and misleading
      // Note: remoteDataSource.getClientStats currently returns the raw map of /clients/kpis as per recent fix.
      // But here we want the detailed charts stats from /clients/stats.
      // We need to clarify which endpoint remoteDataSource.getClientStats calls.
      // In the previous correction to DataSource, getClientStats called /clients/kpis.
      // We should probably rely on separate methods in DataSource for clarity or handle it here.
      // Assuming we will fix DataSource to have distinct methods or we use a new method here.

      // Let's assume we add getClientCharts to DataSource as planned.
      final chartsMap = await remoteDataSource.getClientCharts();
      // Casting to dynamic as temporary measure if interface not updated yet,
      // but ideally we update interface first.
      // Wait, let's update interface first in next step.
      // For now, let's implement the parsing logic assuming data is available.

      return Right(
        ClientStats(
          totalClients: chartsMap['total_clients'] ?? 0,
          byStatus:
              (chartsMap['by_status'] as List?)
                  ?.map((e) => StatusStat.fromJson(e))
                  .toList() ??
              [],
          byPriority:
              (chartsMap['by_priority'] as List?)
                  ?.map((e) => PriorityStat.fromJson(e))
                  .toList() ??
              [],
          bySource:
              (chartsMap['by_source'] as List?)
                  ?.map((e) => SourceStat.fromJson(e))
                  .toList() ??
              [],
          invalidRegistrations:
              (chartsMap['invalid_registrations'] as List?)
                  ?.map((e) => InvalidRegistrationStat.fromJson(e))
                  .toList() ??
              [],
          employeesPerformance:
              (chartsMap['employees_performance'] as List?)
                  ?.map((e) => EmployeePerformanceStat.fromJson(e))
                  .toList() ??
              [],
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientKPI>> getClientKPIs() async {
    try {
      final kpiMap = await remoteDataSource
          .getClientStats(); // Currently points to /clients/kpis
      return Right(ClientKPI.fromJson(kpiMap));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedFilter>> saveFilter(SavedFilter filter) async {
    try {
      await remoteDataSource.saveFilter(filter);
      return Right(filter);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignClient(
    String clientId,
    String employeeId,
  ) async {
    try {
      await remoteDataSource.assignClient(clientId, employeeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateClientsBulkStatus(
    List<String> clientIds,
    int statusId,
  ) async {
    try {
      await remoteDataSource.updateClientsBulkStatus(clientIds, statusId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignClientsBulk(
    List<String> clientIds,
    String employeeId,
  ) async {
    try {
      await remoteDataSource.assignClientsBulk(clientIds, employeeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClientsBulk(
    List<String> clientIds,
  ) async {
    try {
      await remoteDataSource.deleteClientsBulk(clientIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String clientId) async {
    try {
      await remoteDataSource.deleteClient(clientId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DynamicField>>> getDynamicFields(
    String type,
  ) async {
    try {
      final fields = await remoteDataSource.getDynamicFields(type);
      return Right(fields);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DynamicField>> addDynamicField(
    String type,
    DynamicField field,
  ) async {
    try {
      final fieldModel = field as DynamicFieldModel;
      final result = await remoteDataSource.addDynamicField(type, fieldModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDynamicField(
    String type,
    String fieldId,
  ) async {
    try {
      await remoteDataSource.deleteDynamicField(type, fieldId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadClientPdf(String clientId) async {
    try {
      String savePath;
      if (kIsWeb) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savePath = 'client_${clientId}_$timestamp.pdf';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/client_$clientId.pdf';
      }

      await remoteDataSource.downloadClientPdf(clientId, savePath);
      return Right(savePath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportClients(
    ClientFilter? filter, {
    String format = 'csv',
  }) async {
    try {
      String savePath;
      final formatLower = format.toLowerCase();
      final extension = formatLower == 'excel' ? 'xlsx' : formatLower;
      if (kIsWeb) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savePath = 'clients_export_$timestamp.$extension';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savePath = '${dir.path}/clients_export_$timestamp.$extension';
      }

      await remoteDataSource.exportClients(filter, savePath, format: format);
      return Right(savePath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<Invoice>>> getInvoices({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await remoteDataSource.getInvoices(
        clientId: clientId,
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedList<Invoice>(
          items: result.items,
          total: result.total,
          currentPage: result.currentPage,
          perPage: result.perPage,
          lastPage: result.lastPage,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedList<Appointment>>> getAppointments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final result = await remoteDataSource.getAppointments(
        clientId: clientId,
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedList<Appointment>(
          items: result.items,
          total: result.total,
          currentPage: result.currentPage,
          perPage: result.perPage,
          lastPage: result.lastPage,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientFile>>> getFiles(String clientId) async {
    try {
      final result = await remoteDataSource.getFiles(clientId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedFilter>>> getSavedFilters() async {
    try {
      final filters = await remoteDataSource.getSavedFilters();
      return Right(filters);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavedFilter(String id) async {
    try {
      await remoteDataSource.deleteSavedFilter(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientProcedure>>> getProcedures(
    String clientId,
  ) async {
    try {
      final result = await remoteDataSource.getProcedures(clientId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientProcedure>> addProcedure(
    String clientId,
    ClientProcedure procedure,
  ) async {
    try {
      final procedureModel = ClientProcedureModel(
        id: procedure.id,
        title: procedure.title,
        description: procedure.description,
        status: procedure.status,
        dueDate: procedure.dueDate,
        completedAt: procedure.completedAt,
        completedBy: procedure.completedBy,
        createdAt: procedure.createdAt,
      );
      final result = await remoteDataSource.addProcedure(
        clientId,
        procedureModel,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientProcedure>> updateProcedure(
    String clientId,
    ClientProcedure procedure,
  ) async {
    try {
      final procedureModel = ClientProcedureModel(
        id: procedure.id,
        title: procedure.title,
        description: procedure.description,
        status: procedure.status,
        dueDate: procedure.dueDate,
        completedAt: procedure.completedAt,
        completedBy: procedure.completedBy,
        createdAt: procedure.createdAt,
      );
      final result = await remoteDataSource.updateProcedure(
        clientId,
        procedureModel,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProcedure(
    String clientId,
    int procedureId,
  ) async {
    try {
      await remoteDataSource.deleteProcedure(clientId, procedureId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
