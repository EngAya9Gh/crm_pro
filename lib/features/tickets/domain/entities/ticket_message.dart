import '../../../users/domain/entities/user.dart';

class TicketMessage {
  final int id;
  final String content;
  final bool isInternal;
  final User? user;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.content,
    this.isInternal = false,
    this.user,
    required this.createdAt,
  });
}
