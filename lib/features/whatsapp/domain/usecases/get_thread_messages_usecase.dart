import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../entities/whatsapp_message.dart';
import '../repositories/whatsapp_repository.dart';

class GetThreadMessagesUseCase {
  final WhatsappRepository repository;

  GetThreadMessagesUseCase(this.repository);

  Future<Either<ApiException, List<WhatsappMessage>>> call(String threadId, {int page = 1}) {
    return repository.getThreadMessages(threadId, page: page);
  }
}
