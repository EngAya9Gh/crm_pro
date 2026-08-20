import 'package:equatable/equatable.dart';

// If UserMinModel is not available in core, I'll need to find where simple User objects are defined.
// The API docs show "user": { "id": 1, "name": "..." } which matches a minimal user model.

class ClientProcedure extends Equatable {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final UserMin? completedBy;
  final DateTime createdAt;

  const ClientProcedure({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.completedAt,
    this.completedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    dueDate,
    completedAt,
    completedBy,
    createdAt,
  ];
}

class UserMin extends Equatable {
  final int id;
  final String name;

  const UserMin({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
