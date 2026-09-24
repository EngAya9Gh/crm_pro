import '../../domain/entities/ticket.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../users/data/models/user_model.dart';
import 'ticket_category_model.dart';
import 'ticket_message_model.dart';

class TicketModel extends Ticket {
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
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      ticketNumber: json['ticket_number'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      source: json['source'] ?? 'manual',
      slaDueAt: json['sla_due_at'] != null ? DateTime.parse(json['sla_due_at']) : null,
      client: json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      assignedTo: json['assigned_to'] != null ? UserModel.fromJson(json['assigned_to']) : null,
      category: json['category'] != null ? TicketCategoryModel.fromJson(json['category']) : null,
      subCategory: json['sub_category'] != null ? TicketCategoryModel.fromJson(json['sub_category']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as List).map((e) => TicketMessageModel.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'client_id': client?.id,
      'assigned_to': assignedTo?.id,
      'category_id': category?.id,
      'sub_category_id': subCategory?.id,
      'priority': priority,
      'source': source,
      'status': status,
    };
  }
}
