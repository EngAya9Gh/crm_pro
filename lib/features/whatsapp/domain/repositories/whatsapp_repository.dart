import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../entities/whatsapp_thread.dart';
import '../entities/whatsapp_message.dart';

abstract class WhatsappRepository {
  Future<Either<ApiException, List<WhatsappThread>>> getThreads({int page = 1});
  
  Future<Either<ApiException, List<WhatsappMessage>>> getThreadMessages(
      String threadId, {int page = 1});
      
  Future<Either<ApiException, WhatsappMessage>> sendMessage({
    required int? clientId,
    required String? phone,
    required String type,
    String? content,
    String? mediaUrl,
    String? mediaType,
  });

  Future<Either<ApiException, void>> replyToThread({
    required String threadId,
    required String type,
    String? mediaType,
    String? content,
    int? clientId,
    String? clientPhone,
    List<int>? fileBytes,
    String? fileName,
    bool useSendEndpoint = false,
  });
}
