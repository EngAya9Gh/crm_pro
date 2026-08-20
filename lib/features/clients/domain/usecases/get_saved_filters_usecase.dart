import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_filter.dart';
import '../repositories/clients_repository.dart';

class GetSavedFilters {
  final ClientsRepository repository;

  GetSavedFilters(this.repository);

  Future<Either<Failure, List<SavedFilter>>> call() async {
    return await repository.getSavedFilters();
  }
}
