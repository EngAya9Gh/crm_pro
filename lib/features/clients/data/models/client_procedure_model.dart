import '../../domain/entities/client_procedure.dart';

class ClientProcedureModel extends ClientProcedure {
  const ClientProcedureModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    super.dueDate,
    super.completedAt,
    super.completedBy,
    required super.createdAt,
  });

  factory ClientProcedureModel.fromJson(Map<String, dynamic> json) {
    return ClientProcedureModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      completedBy: json['completed_by'] != null
          ? UserMinModel.fromJson(json['completed_by'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
    };

    if (id != 0) {
      map['id'] = id;
    }

    if (dueDate != null) {
      // Format as YYYY-MM-DD
      map['due_date'] = dueDate!.toIso8601String().split('T')[0];
    }

    // We avoid sending created_at, completed_at, completed_by to let the backend handle them.
    return map;
  }
}

class UserMinModel extends UserMin {
  const UserMinModel({required super.id, required super.name});

  factory UserMinModel.fromJson(Map<String, dynamic> json) {
    return UserMinModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
