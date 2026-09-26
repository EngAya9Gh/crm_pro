import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/api_response.dart';
import '../../../../core/utils/end_points.dart';
import '../models/ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../models/ticket_category_model.dart';
import 'tickets_remote_datasource.dart';

class TicketsRemoteDataSourceImpl implements TicketsRemoteDataSource {
  final ApiClient apiClient;

  TicketsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<TicketModel>>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int? rating,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (status != null) 'status': status,
      if (clientId != null) 'client_id': clientId,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (categoryId != null) 'category_id': categoryId,
      if (rating != null) 'rating': rating,
    };

    return await apiClient.get<List<TicketModel>>(
      EndPoints.tickets,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<TicketModel> createTicket(TicketModel ticket) async {
    final response = await apiClient.post<TicketModel>(
      EndPoints.tickets,
      data: ticket.toJson(),
      fromJson: (json) => TicketModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<TicketModel> updateTicket(int id, TicketModel ticket) async {
    final response = await apiClient.put<TicketModel>(
      EndPoints.ticket(id.toString()),
      data: ticket.toJson(),
      fromJson: (json) => TicketModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<TicketMessageModel>> getTicketMessages(int ticketId) async {
    final response = await apiClient.get<List<TicketMessageModel>>(
      EndPoints.ticketMessages(ticketId.toString()),
      fromJson: (json) => (json as List)
          .map((e) => TicketMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<TicketMessageModel> addTicketMessage(int ticketId, String content, bool isInternal) async {
    final response = await apiClient.post<TicketMessageModel>(
      EndPoints.ticketMessages(ticketId.toString()),
      data: {'content': content, 'is_internal': isInternal},
      fromJson: (json) => TicketMessageModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<TicketCategoryModel>> getCategories() async {
    final response = await apiClient.get<List<TicketCategoryModel>>(
      EndPoints.ticketCategories,
      fromJson: (json) => (json as List)
          .map((e) => TicketCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<TicketCategoryModel> createCategory(TicketCategoryModel category) async {
    final response = await apiClient.post<TicketCategoryModel>(
      EndPoints.ticketCategories,
      data: category.toJson(),
      fromJson: (json) => TicketCategoryModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<TicketCategoryModel> updateCategory(int id, TicketCategoryModel category) async {
    final response = await apiClient.put<TicketCategoryModel>(
      EndPoints.ticketCategory(id.toString()),
      data: category.toJson(),
      fromJson: (json) => TicketCategoryModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteCategory(int id) async {
    await apiClient.delete<void>(
      EndPoints.ticketCategory(id.toString()),
      fromJson: (_) {},
    );
  }
}
