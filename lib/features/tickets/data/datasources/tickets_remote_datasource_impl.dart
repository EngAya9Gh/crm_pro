import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/ticket_model.dart';
import '../models/ticket_message_model.dart';
import '../models/ticket_category_model.dart';
import 'tickets_remote_datasource.dart';

class TicketsRemoteDataSourceImpl implements TicketsRemoteDataSource {
  final ApiClient apiClient;

  TicketsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TicketModel>> getTickets({
    String? status,
    int? clientId,
    int? assignedTo,
    int? categoryId,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (status != null) 'status': status,
      if (clientId != null) 'client_id': clientId,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (categoryId != null) 'category_id': categoryId,
    };

    final response = await apiClient.get(
      EndPoints.tickets,
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => TicketModel.fromJson(json))
        .toList();
  }

  @override
  Future<TicketModel> createTicket(TicketModel ticket) async {
    final response = await apiClient.post(
      EndPoints.tickets,
      data: ticket.toJson(),
    );
    return TicketModel.fromJson(response.data['data']);
  }

  @override
  Future<TicketModel> updateTicket(int id, TicketModel ticket) async {
    final response = await apiClient.put(
      EndPoints.ticket(id.toString()),
      data: ticket.toJson(),
    );
    return TicketModel.fromJson(response.data['data']);
  }

  @override
  Future<List<TicketMessageModel>> getTicketMessages(int ticketId) async {
    final response = await apiClient.get(
      EndPoints.ticketMessages(ticketId.toString()),
    );
    return (response.data['data'] as List)
        .map((json) => TicketMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<TicketMessageModel> addTicketMessage(int ticketId, String content, bool isInternal) async {
    final response = await apiClient.post(
      EndPoints.ticketMessages(ticketId.toString()),
      data: {
        'content': content,
        'is_internal': isInternal,
      },
    );
    return TicketMessageModel.fromJson(response.data['data']);
  }

  @override
  Future<List<TicketCategoryModel>> getCategories() async {
    final response = await apiClient.get(EndPoints.ticketCategories);
    return (response.data['data'] as List)
        .map((json) => TicketCategoryModel.fromJson(json))
        .toList();
  }

  @override
  Future<TicketCategoryModel> createCategory(TicketCategoryModel category) async {
    final response = await apiClient.post(
      EndPoints.ticketCategories,
      data: category.toJson(),
    );
    return TicketCategoryModel.fromJson(response.data['data']);
  }

  @override
  Future<TicketCategoryModel> updateCategory(int id, TicketCategoryModel category) async {
    final response = await apiClient.put(
      EndPoints.ticketCategory(id.toString()),
      data: category.toJson(),
    );
    return TicketCategoryModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await apiClient.delete(EndPoints.ticketCategory(id.toString()));
  }
}
