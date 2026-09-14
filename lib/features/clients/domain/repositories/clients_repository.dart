import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_brief.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_file.dart';
import 'package:crm_wakeel/features/clients/domain/entities/comment.dart';
import 'package:crm_wakeel/features/clients/domain/entities/saved_filter.dart';
import 'package:crm_wakeel/features/clients/domain/entities/timeline_event.dart';
import 'package:crm_wakeel/features/clients/domain/entities/dynamic_field.dart';
import 'package:dartz/dartz.dart';

import 'package:crm_wakeel/features/clients/domain/entities/client_stats.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_kpi.dart';
import 'package:crm_wakeel/features/invoices/domain/entities/invoice.dart';
import 'package:crm_wakeel/features/appointments/domain/entities/appointment.dart';
import 'package:crm_wakeel/core/common/models/paginated_list.dart';
import '../entities/client_procedure.dart';

abstract class ClientsRepository {
  Future<Either<Failure, PaginatedList<Client>>> getClients({
    ClientFilter? filter,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, PaginatedList<ClientBrief>>> getClientsList({
    int page = 1,
    int perPage = 15,
    String? search,
  });

  Future<Either<Failure, Client>> getClientDetails(String id);

  Future<Either<Failure, Client>> addClient(Client client);

  Future<Either<Failure, Client>> updateClient(Client client);

  Future<Either<Failure, void>> changeClientStatus(
    String clientId,
    int statusId,
  );

  Future<Either<Failure, Comment>> addComment(
    String clientId,
    Comment comment, {
    List<dynamic>? attachments,
    List<String>? mentionIds,
  });

  Future<Either<Failure, PaginatedList<Comment>>> getComments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  Future<Either<Failure, ClientFile>> uploadFile(
    String clientId,
    dynamic file,
    String type,
  );

  Future<Either<Failure, List<TimelineEvent>>> getTimeline(String clientId);

  Future<Either<Failure, ClientStats>> getClientStats();
  Future<Either<Failure, ClientKPI>> getClientKPIs();

  Future<Either<Failure, SavedFilter>> saveFilter(SavedFilter filter);

  Future<Either<Failure, void>> assignClient(
    String clientId,
    String employeeId,
  );

  Future<Either<Failure, void>> updateClientsBulkStatus(
    List<String> clientIds,
    int statusId,
  );
  Future<Either<Failure, void>> assignClientsBulk(
    List<String> clientIds,
    String employeeId,
  );
  Future<Either<Failure, void>> deleteClientsBulk(List<String> clientIds);
  Future<Either<Failure, void>> deleteClient(String clientId);

  Future<Either<Failure, List<DynamicField>>> getDynamicFields(String type);
  Future<Either<Failure, DynamicField>> addDynamicField(
    String type,
    DynamicField field,
  );

  Future<Either<Failure, void>> deleteDynamicField(String type, String fieldId);

  Future<Either<Failure, String>> downloadClientPdf(String clientId);
  Future<Either<Failure, String>> exportClients(
    ClientFilter? filter, {
    String format = 'csv',
  });

  Future<Either<Failure, PaginatedList<Invoice>>> getInvoices({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  Future<Either<Failure, PaginatedList<Appointment>>> getAppointments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  Future<Either<Failure, List<ClientFile>>> getFiles(String clientId);

  Future<Either<Failure, List<SavedFilter>>> getSavedFilters();
  Future<Either<Failure, void>> deleteSavedFilter(String id);

  Future<Either<Failure, List<ClientProcedure>>> getProcedures(String clientId);
  Future<Either<Failure, ClientProcedure>> addProcedure(
    String clientId,
    ClientProcedure procedure,
  );
  Future<Either<Failure, ClientProcedure>> updateProcedure(
    String clientId,
    ClientProcedure procedure,
  );
  Future<Either<Failure, void>> deleteProcedure(
    String clientId,
    int procedureId,
  );
}
