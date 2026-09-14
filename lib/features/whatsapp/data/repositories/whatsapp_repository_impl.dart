import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/whatsapp_message.dart';
import '../../domain/entities/whatsapp_thread.dart';
import '../../domain/repositories/whatsapp_repository.dart';
import '../datasources/whatsapp_remote_datasource.dart';

class WhatsappRepositoryImpl implements WhatsappRepository {
  final WhatsappRemoteDataSource remoteDataSource;

  WhatsappRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, List<WhatsappThread>>> getThreads({
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.getThreads(page: page);
      return Right(result);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<WhatsappMessage>>> getThreadMessages(
    String threadId, {
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.getThreadMessages(
        threadId,
        page: page,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      if (useSendEndpoint && fileBytes != null && fileBytes.isNotEmpty) {
        // Step 1: Upload media
        final uploadData = <String, dynamic>{
          'type': type,
          if (mediaType != null) 'media_type': mediaType,
          'file': MultipartFile.fromBytes(
            fileBytes,
            filename: fileName ?? 'file',
          ),
        };

        final mediaUrl = await remoteDataSource.uploadMedia(
          threadId,
          data: uploadData,
        );

        // Step 2: Send message with media url
        final messageData = <String, dynamic>{
          'type': type, // media
          if (mediaType != null) 'media_type': mediaType,
          'url': mediaUrl,
        };

        await remoteDataSource.replyToThread(
          threadId,
          data: messageData,
          isFormData: false,
        );
      } else {
        // Use /whatsapp/threads/{id}/messages for text replies
        final data = <String, dynamic>{
          'type': type, // should be 'text'
          if (content != null && content.isNotEmpty) 'content': content,
        };
        await remoteDataSource.replyToThread(
          threadId,
          data: data,
          isFormData: false,
        );
      }
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, WhatsappMessage>> sendMessage({
    required int? clientId,
    required String? phone,
    required String type,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    try {
      final data = {
        if (clientId != null) 'client_id': clientId,
        if (phone != null) 'phone': phone,
        'type': type,
        if (content != null) 'message': content,
        if (mediaUrl != null) 'url': mediaUrl,
        if (mediaType != null) 'media_type': mediaType,
      };
      final result = await remoteDataSource.sendMessage(data);
      return Right(result);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownException(message: e.toString()));
    }
  }
}
