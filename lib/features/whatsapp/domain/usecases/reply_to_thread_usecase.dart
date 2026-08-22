import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../repositories/whatsapp_repository.dart';

class ReplyToThreadUseCase {
  final WhatsappRepository repository;

  ReplyToThreadUseCase(this.repository);

  Future<Either<ApiException, void>> call({
    required String threadId,
    required String type,
    String? mediaType,
    String? content,
    int? clientId,
    String? clientPhone,
    List<int>? fileBytes,
    String? fileName,
    bool useSendEndpoint = false,
  }) {
    return repository.replyToThread(
      threadId: threadId,
      type: type,
      mediaType: mediaType,
      content: content,
      clientId: clientId,
      clientPhone: clientPhone,
      fileBytes: fileBytes,
      fileName: fileName,
      useSendEndpoint: useSendEndpoint,
    );
  }
}
