import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../entities/whatsapp_thread.dart';
import '../repositories/whatsapp_repository.dart';

class GetWhatsappThreadsUseCase {
  final WhatsappRepository repository;

  GetWhatsappThreadsUseCase(this.repository);

  Future<Either<ApiException, List<WhatsappThread>>> call({int page = 1}) {
    return repository.getThreads(page: page);
  }
}
