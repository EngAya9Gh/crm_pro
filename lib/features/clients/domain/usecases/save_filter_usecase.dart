import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_filter.dart';
import '../repositories/clients_repository.dart';

class SaveFilterUseCase {
  final ClientsRepository repository;

  SaveFilterUseCase(this.repository);

  Future<Either<Failure, SavedFilter>> call(SavedFilter filter) async {
    return await repository.saveFilter(filter);
  }
}
