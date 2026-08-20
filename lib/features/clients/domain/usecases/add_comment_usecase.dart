import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/entities/comment.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class AddComment {
  final ClientsRepository repository;

  AddComment(this.repository);

  Future<Either<Failure, Comment>> call(
    String clientId,
    Comment comment, {
    List<dynamic>? attachments,
    List<String>? mentionIds,
  }) async {
    return await repository.addComment(
      clientId,
      comment,
      attachments: attachments,
      mentionIds: mentionIds,
    );
  }
}
