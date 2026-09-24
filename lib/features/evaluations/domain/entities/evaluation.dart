import '../../../clients/domain/entities/client.dart';
import '../../../users/domain/entities/user.dart';
import 'evaluation_type.dart';

class Evaluation {
  final int id;
  final int rating;
  final String? notes;
  final String channel;
  final Client? client;
  final User? assignedUser;
  final EvaluationType? type;
  final DateTime createdAt;

  Evaluation({
    required this.id,
    required this.rating,
    this.notes,
    required this.channel,
    this.client,
    this.assignedUser,
    this.type,
    required this.createdAt,
  });
}
