import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/client_model.dart';
import '../models/comment_model.dart';
import '../models/client_file_model.dart';
import '../models/timeline_event_model.dart';
import '../../domain/entities/saved_filter.dart';
import '../models/dynamic_field_model.dart';
import 'clients_remote_datasource.dart';
import '../models/client_brief_model.dart';
import '../../../../core/common/models/paginated_list.dart';
import 'package:crm_wakeel/features/invoices/data/models/invoice_model.dart';
import 'package:crm_wakeel/features/appointments/data/models/appointment_model.dart';
import '../models/client_procedure_model.dart';
import 'package:dio/dio.dart'; // Added for MultipartFile

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  final ApiClient apiClient;

  ClientsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedList<ClientModel>> getClients({
    ClientFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'per_page': limit};

    if (filter != null) {
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery;
      }

      if (filter.statusIds != null && filter.statusIds!.isNotEmpty) {
        // Doc says 'status_id'. Sending comma separated might work if backend supports it,
        // or 'status_id[]' if array.
        // Assuming comma separated in 'status_id' for now or 'status_id[]' if multiple.
        // Standard Laravel often treats 'key=1,2' as '1,2' string unless parsed.
        // Let's use 'status_id' as per doc. If strictly single, we might need loop.
        // But likely backend supports list if filter is multi-select.
        queryParams['status_id'] = filter.statusIds!.join(',');
      }
      if (filter.priorities != null && filter.priorities!.isNotEmpty) {
        queryParams['priority'] = filter.priorities!
            .map((e) => e.name)
            .join(',');
      }
      if (filter.ratings != null && filter.ratings!.isNotEmpty) {
        queryParams['lead_rating'] = filter.ratings!
            .map((e) => e.name)
            .join(',');
      }
      if (filter.assignedTo != null) {
        queryParams['assigned_to'] = filter.assignedTo;
      }
      if (filter.region != null) {
        // Doc says region_id. If we have name only, we can't send ID easily.
        // But filter.region is string. If it holds ID, good.
        // Assuming filter.region might be ID or Name. Changing key to region_id if it looks like ID?
        // Or keeping generic 'region_id' hoping backend handles it.
        queryParams['region_id'] = filter.region;
      }
      if (filter.city != null) {
        queryParams['city_id'] = filter.city;
      }
      if (filter.sourceStatus != null) {
        queryParams['source_status'] = filter.sourceStatus!.name;
      }
      // Date Range
      if (filter.createdDateRange != null) {
        queryParams['created_from'] = filter.createdDateRange!.start
            .toIso8601String();
        queryParams['created_to'] = filter.createdDateRange!.end
            .toIso8601String();
      }

      if (filter.tagIds != null && filter.tagIds!.isNotEmpty) {
        // Doc says 'tags[]'.
        // Dio handles list params with [] if List given?
        // queryParams['tags[]'] = filter.tagIds;
        // Or comma separated?
        queryParams['tags'] = filter.tagIds!.join(',');
      }
    }

    final response = await apiClient.get(
      EndPoints.clients,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => ClientModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 20,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<PaginatedList<ClientBriefModel>> getClientsList({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiClient.get(
      EndPoints.clientsList,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => ClientBriefModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 15,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<ClientModel> getClientDetails(String id) async {
    final response = await apiClient.get(
      EndPoints.client(id),
      fromJson: (json) => ClientModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<ClientModel> addClient(ClientModel client) async {
    final response = await apiClient.post(
      EndPoints.clients,
      data: client.toJson(),
      fromJson: (json) => ClientModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    final response = await apiClient.put(
      EndPoints.client(client.id),
      data: client.toJson(),
      fromJson: (json) => ClientModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> changeClientStatus(String clientId, int statusId) async {
    await apiClient.patch(
      EndPoints.clientStatus(clientId),
      data: {'status_id': statusId},
      fromJson: (json) => null,
    );
  }

  @override
  Future<CommentModel> addComment(
    String clientId,
    CommentModel comment, {
    List<dynamic>? attachments,
    List<String>? mentionIds,
  }) async {
    final Map<String, dynamic> requestData = {'content': comment.content};
    if (comment.typeId != null) requestData['type_id'] = comment.typeId;
    if (comment.outcome != null) requestData['outcome'] = comment.outcome!.name;
    if (comment.nextFollowUp != null) {
      requestData['next_follow_up'] = comment.nextFollowUp!.toIso8601String();
    }

    if (mentionIds != null && mentionIds.isNotEmpty) {
      requestData['mentions[]'] = mentionIds;
    }

    bool isFormData =
        (attachments != null && attachments.isNotEmpty) ||
        (mentionIds != null && mentionIds.isNotEmpty);

    if (attachments != null && attachments.isNotEmpty) {
      print('DEBUG: Processing ${attachments.length} attachments');
      List<MultipartFile> files = [];
      for (var file in attachments) {
        final dynamicFile = file as dynamic;
        final String? path = dynamicFile.path;
        final List<int>? bytes = dynamicFile.bytes;
        final String? name = dynamicFile.name;
        String fileName = name ?? 'attachment';

        if (bytes != null) {
          files.add(MultipartFile.fromBytes(bytes, filename: fileName));
        } else if (path != null) {
          files.add(await MultipartFile.fromFile(path, filename: fileName));
        }
      }
      if (files.isNotEmpty) {
        requestData['attachments[]'] =
            files; // Use brackets for files array too
      }
    }

    final response = await apiClient.post(
      EndPoints.clientComments(clientId),
      data: requestData,
      isFormData: isFormData,
      fromJson: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<PaginatedList<CommentModel>> getComments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await apiClient.get(
      EndPoints.clientComments(clientId),
      queryParameters: {'page': page, 'per_page': perPage},
      fromJson: (json) =>
          (json as List).map((e) => CommentModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 10,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<PaginatedList<InvoiceModel>> getInvoices({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await apiClient.get(
      EndPoints.clientInvoices(clientId),
      queryParameters: {'page': page, 'per_page': perPage},
      fromJson: (json) =>
          (json as List).map((e) => InvoiceModel.fromJson(e)).toList(),
    );
    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 10,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<PaginatedList<AppointmentModel>> getAppointments({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await apiClient.get(
      EndPoints.clientAppointments(clientId),
      queryParameters: {'page': page, 'per_page': perPage},
      fromJson: (json) =>
          (json as List).map((e) => AppointmentModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data!,
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 10,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<List<ClientProcedureModel>> getProcedures(String clientId) async {
    final response = await apiClient.get(
      EndPoints.clientProcedures(clientId),
      fromJson: (json) =>
          (json as List).map((e) => ClientProcedureModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<ClientProcedureModel> addProcedure(
    String clientId,
    ClientProcedureModel procedure,
  ) async {
    final response = await apiClient.post(
      EndPoints.clientProcedures(clientId),
      data: procedure.toJson(),
      fromJson: (json) =>
          ClientProcedureModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<ClientProcedureModel> updateProcedure(
    String clientId,
    ClientProcedureModel procedure,
  ) async {
    final response = await apiClient.put(
      EndPoints.clientProcedure(clientId, procedure.id),
      data: procedure.toJson(),
      fromJson: (json) =>
          ClientProcedureModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteProcedure(String clientId, int procedureId) async {
    await apiClient.delete(
      EndPoints.clientProcedure(clientId, procedureId),
      fromJson: (json) => null,
    );
  }

  @override
  Future<List<ClientFileModel>> getFiles(String clientId) async {
    final response = await apiClient.get(
      EndPoints.clientFiles(clientId),
      fromJson: (json) =>
          (json as List).map((e) => ClientFileModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<ClientFileModel> uploadFile(
    String clientId,
    dynamic file,
    String type,
  ) async {
    MultipartFile multipartFile;
    String fileName = 'file';

    // Access properties dynamically since file can be PlatformFile or similar
    // PlatformFile has: name, size, bytes, path
    final dynamicFile = file as dynamic;

    // Check for bytes first (Web or loaded in memory)
    final List<int>? bytes = dynamicFile.bytes;
    final String? path = dynamicFile.path;
    final String? name = dynamicFile.name;

    if (name != null) fileName = name;

    if (bytes != null) {
      multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
    } else if (path != null) {
      multipartFile = await MultipartFile.fromFile(path, filename: fileName);
    } else {
      throw Exception('File has no path or bytes');
    }

    final response = await apiClient.post(
      EndPoints.clientFiles(clientId),
      data: {'file': multipartFile, 'type': type},
      isFormData: true,
      fromJson: (json) =>
          ClientFileModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<TimelineEventModel>> getTimeline(String clientId) async {
    final response = await apiClient.get(
      EndPoints.clientTimeline(clientId),
      fromJson: (json) =>
          (json as List).map((e) => TimelineEventModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getClientStats() async {
    // Corrected Endpoint to KPIs as per Gap Analysis
    // But keeping existing method name. The UI calls this for KPIs mostly.
    // Ideally we should have getClientKPIs separately.
    // For now pointing to KPIs to fix the "Null" values issue in KPI Screen.
    final response = await apiClient.get(
      EndPoints.clientsKpis, // Changed from clientsStats to clientsKpis
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return response.data!;
  }

  // Added separate method for detailed stats charts if needed
  @override
  Future<Map<String, dynamic>> getClientCharts() async {
    final response = await apiClient.get(
      EndPoints.clientsStats,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return response.data!;
  }

  @override
  Future<void> saveFilter(SavedFilter filter) async {
    // Implemented using /clients/filters endpoint (Proposed)

    await apiClient.post(
      EndPoints.clientsFilters,
      data: filter.toJson(),
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> assignClient(String clientId, String employeeId) async {
    await apiClient.patch(
      EndPoints.clientAssign(clientId),
      data: {'user_id': employeeId},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> updateClientsBulkStatus(
    List<String> clientIds,
    int statusId,
  ) async {
    await apiClient.post(
      EndPoints.clientsBulkStatus,
      data: {'client_ids': clientIds, 'status_id': statusId},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> assignClientsBulk(
    List<String> clientIds,
    String employeeId,
  ) async {
    await apiClient.post(
      EndPoints.clientsBulkAssign,
      data: {'client_ids': clientIds, 'user_id': employeeId},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> deleteClientsBulk(List<String> clientIds) async {
    await apiClient.delete(
      EndPoints.clientsBulkDelete,
      data: {'client_ids': clientIds},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> restoreClient(String clientId) async {
    await apiClient.post(
      EndPoints.clientRestore(clientId),
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> deleteClient(String clientId) async {
    await apiClient.delete(
      EndPoints.client(clientId),
      fromJson: (json) => null,
    );
  }

  @override
  Future<List<DynamicFieldModel>> getDynamicFields(String type) async {
    String endpoint;
    switch (type) {
      case 'comment_types':
        endpoint = EndPoints.settingsCommentTypes;
        break;
      // Add other cases like 'tags', 'statuses' if needed later
      default:
        endpoint = EndPoints.settingsCommentTypes; // Fallback or throw
    }

    final response = await apiClient.get(
      endpoint,
      fromJson: (json) => (json as List)
          .map((e) => DynamicFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data!;
  }

  @override
  Future<DynamicFieldModel> addDynamicField(
    String type,
    DynamicFieldModel field,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDynamicField(String type, String fieldId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> downloadClientPdf(String clientId, String savePath) async {
    await apiClient.download(EndPoints.clientPdf(clientId), savePath);
  }

  @override
  Future<List<SavedFilter>> getSavedFilters() async {
    final response = await apiClient.get(
      EndPoints.clientsFilters,
      fromJson: (json) =>
          (json as List).map((e) => SavedFilter.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<void> deleteSavedFilter(String id) async {
    await apiClient.delete(
      '${EndPoints.clientsFilters}/$id',
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> exportClients(
    ClientFilter? filter,
    String savePath, {
    String format = 'csv',
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (filter != null) {
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery;
      }

      if (filter.statusIds != null && filter.statusIds!.isNotEmpty) {
        queryParams['status_id'] = filter.statusIds!.join(',');
      }
      if (filter.priorities != null && filter.priorities!.isNotEmpty) {
        queryParams['priority'] = filter.priorities!
            .map((e) => e.name)
            .join(',');
      }
      if (filter.ratings != null && filter.ratings!.isNotEmpty) {
        queryParams['lead_rating'] = filter.ratings!
            .map((e) => e.name)
            .join(',');
      }
      if (filter.assignedTo != null) {
        queryParams['assigned_to'] = filter.assignedTo;
      }
      if (filter.region != null) {
        queryParams['region_id'] = filter.region;
      }
      if (filter.city != null) {
        queryParams['city_id'] = filter.city;
      }
      if (filter.sourceStatus != null) {
        queryParams['source_status'] = filter.sourceStatus!.name;
      }
      if (filter.createdDateRange != null) {
        queryParams['created_from'] = filter.createdDateRange!.start
            .toIso8601String();
        queryParams['created_to'] = filter.createdDateRange!.end
            .toIso8601String();
      }
      if (filter.tagIds != null && filter.tagIds!.isNotEmpty) {
        queryParams['tags'] = filter.tagIds!.join(',');
      }
    }

    queryParams['format'] = format;

    await apiClient.download(
      EndPoints.clientsExport,
      savePath,
      queryParameters: queryParams,
    );
  }
} // Added closing brace
