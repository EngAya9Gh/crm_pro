import '../models/client_model.dart';
import '../models/client_brief_model.dart';
import '../models/comment_model.dart';
import '../models/client_procedure_model.dart';
import '../models/client_file_model.dart';
import '../models/timeline_event_model.dart';
import '../../domain/entities/saved_filter.dart';
import '../models/dynamic_field_model.dart';
import 'package:crm_wakeel/features/invoices/data/models/invoice_model.dart';
import 'package:crm_wakeel/features/appointments/data/models/appointment_model.dart';
import '../../../../core/common/models/paginated_list.dart';

abstract class ClientsRemoteDataSource {
  Future<PaginatedList<ClientModel>> getClients({
    ClientFilter? filter,
    int page = 1,
    int limit = 20,
  });

  Future<PaginatedList<ClientBriefModel>> getClientsList({
    int page = 1,
    int perPage = 15,
    String? search,
  });

  Future<ClientModel> getClientDetails(String id);

  Future<ClientModel> addClient(ClientModel client);

  Future<ClientModel> updateClient(ClientModel client);

  Future<void> changeClientStatus(String clientId, int statusId);

  Future<CommentModel> addComment(
    String clientId,
    CommentModel comment, {
    List<dynamic>? attachments,
    List<String>? mentionIds,
  });

  Future<PaginatedList<CommentModel>> getComments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  // New Methods
  Future<PaginatedList<InvoiceModel>> getInvoices({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  Future<PaginatedList<AppointmentModel>> getAppointments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  });

  Future<List<ClientFileModel>> getFiles(String clientId);

  Future<ClientFileModel> uploadFile(
    String clientId,
    dynamic file,
    String type,
  );

  Future<List<TimelineEventModel>> getTimeline(String clientId);

  Future<Map<String, dynamic>> getClientStats();
  Future<Map<String, dynamic>> getClientCharts();

  Future<void> saveFilter(SavedFilter filter);

  Future<void> assignClient(String clientId, String employeeId);

  Future<void> updateClientsBulkStatus(List<String> clientIds, int statusId);
  Future<void> assignClientsBulk(List<String> clientIds, String employeeId);
  Future<void> deleteClientsBulk(List<String> clientIds);
  Future<void> restoreClient(String clientId);
  Future<void> deleteClient(String clientId);

  Future<List<DynamicFieldModel>> getDynamicFields(String type);
  Future<DynamicFieldModel> addDynamicField(
    String type,
    DynamicFieldModel field,
  );

  Future<void> deleteDynamicField(String type, String fieldId);

  Future<void> downloadClientPdf(String clientId, String savePath);
  Future<void> exportClients(ClientFilter? filter, String savePath);

  Future<List<SavedFilter>> getSavedFilters();
  Future<void> deleteSavedFilter(String id);

  Future<List<ClientProcedureModel>> getProcedures(String clientId);
  Future<ClientProcedureModel> addProcedure(
    String clientId,
    ClientProcedureModel procedure,
  );
  Future<ClientProcedureModel> updateProcedure(
    String clientId,
    ClientProcedureModel procedure,
  );
  Future<void> deleteProcedure(String clientId, int procedureId);
}
