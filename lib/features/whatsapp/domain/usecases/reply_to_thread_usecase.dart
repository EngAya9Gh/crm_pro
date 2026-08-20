import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../repositories/whatsapp_repository.dart';

class ReplyToThreadUseCase {
  final WhatsappRepository repository;

  ReplyToThreadUseCase(this.repository);

  Future<Either<ApiException, void>> call({
    required String threadId,
    required String type,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) {
    return repository.replyToThread(
      threadId: threadId,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
    );
  }
}
