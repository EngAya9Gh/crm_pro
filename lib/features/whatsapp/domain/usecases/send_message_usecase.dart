import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../entities/whatsapp_message.dart';
import '../repositories/whatsapp_repository.dart';

class SendWhatsappMessageUseCase {
  final WhatsappRepository repository;

  SendWhatsappMessageUseCase(this.repository);

  Future<Either<ApiException, WhatsappMessage>> call({
    required String type,
    int? clientId,
    String? phone,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) {
    return repository.sendMessage(
      clientId: clientId,
      phone: phone,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
    );
  }
}
