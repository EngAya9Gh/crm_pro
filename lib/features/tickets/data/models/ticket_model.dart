import '../../domain/entities/ticket.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/entities/client_enums.dart';
import '../../../clients/domain/entities/status_entity.dart';
import '../../../users/domain/entities/user.dart';
import 'ticket_category_model.dart';
import 'ticket_message_model.dart';

class TicketModel extends Ticket {
  final String? clientIdStr;
  final int? assignedToId;
  final int? categoryId;
  final int? subCategoryId;
  final Map<String, dynamic>? evaluation;

  TicketModel({
    required super.id,
    required super.ticketNumber,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    required super.source,
    super.slaDueAt,
    super.client,
    super.assignedTo,
    super.category,
    super.subCategory,
    super.messages,
    required super.createdAt,
    super.closedAt,
    this.clientIdStr,
    this.assignedToId,
    this.categoryId,
    this.subCategoryId,
    this.evaluation,
    super.lastMessage,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      ticketNumber: json['ticket_number']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      source: json['source'] ?? 'manual',
      slaDueAt: json['sla_due_at'] != null
          ? DateTime.tryParse(json['sla_due_at'].toString())
          : null,
      client: (json['client'] != null && json['client'] is Map<String, dynamic>)
          ? _TicketPartialClient.fromJson(json['client'])
          : null,
      assignedTo: (json['assigned_to'] != null && json['assigned_to'] is Map<String, dynamic>)
          ? _TicketPartialUser.fromJson(json['assigned_to'])
          : null,
      category: (json['category'] != null && json['category'] is Map<String, dynamic>)
          ? TicketCategoryModel.fromJson(json['category'])
          : null,
      subCategory: (json['sub_category'] != null && json['sub_category'] is Map<String, dynamic>)
          ? TicketCategoryModel.fromJson(json['sub_category'])
          : ((json['subcategory'] != null && json['subcategory'] is Map<String, dynamic>)
              ? TicketCategoryModel.fromJson(json['subcategory'])
              : null),
      messages: (json['messages'] != null && json['messages'] is List)
          ? (json['messages'] as List)
              .map((e) => TicketMessageModel.fromJson(e))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'].toString())
          : null,
      evaluation: (json['evaluations'] != null && json['evaluations'] is List && (json['evaluations'] as List).isNotEmpty)
          ? (json['evaluations'] as List).first as Map<String, dynamic>
          : ((json['evaluation'] != null && json['evaluation'] is Map<String, dynamic>) ? json['evaluation'] as Map<String, dynamic> : null),
      lastMessage: json['last_message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'client_id': clientIdStr ?? client?.id,
      'assigned_to': assignedToId ?? assignedTo?.id,
      'assigned_user_id': assignedToId ?? assignedTo?.id, // Added for compatibility
      'category_id': categoryId ?? category?.id,
      'sub_category_id': subCategoryId ?? subCategory?.id,
      'subcategory_id': subCategoryId ?? subCategory?.id, // Added to support both backend conventions
      'priority': priority,
      'source': source,
      'status': status,
    };
    if (evaluation != null) {
      map['evaluation'] = evaluation;
    }
    return map;
  }
}

/// Lightweight Client stub for partial API responses (tickets, evaluations)
/// The API returns only {id, name, phone} for client in ticket lists.
class _TicketPartialClient extends Client {
  _TicketPartialClient({
    required String id,
    required String name,
    String phone = '',
  }) : super(
          id: id,
          name: name,
          phone: phone,
          region: '',
          city: '',
          status: const StatusModel(id: 0, name: '', color: '#000000'),
          priority: ClientPriority.medium,
          sourceStatus: SourceStatus.valid,
          tags: const [],
          files: const [],
          comments: const [],
          invoices: const [],
          appointments: const [],
          timeline: const [],
          createdAt: DateTime.now(),
        );

  factory _TicketPartialClient.fromJson(Map<String, dynamic> json) {
    return _TicketPartialClient(
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

/// Lightweight User stub for partial API responses (assigned_to in tickets)
/// The API returns only {id, name, permissions_list, role} for assigned_to.
class _TicketPartialUser extends User {
  const _TicketPartialUser({required super.id, required super.name})
      : super(email: '');

  factory _TicketPartialUser.fromJson(Map<String, dynamic> json) {
    return _TicketPartialUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
    );
  }
}
