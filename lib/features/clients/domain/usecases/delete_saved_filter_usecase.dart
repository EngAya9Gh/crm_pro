import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clients_repository.dart';

class DeleteSavedFilter {
  final ClientsRepository repository;

  DeleteSavedFilter(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSavedFilter(id);
  }
}
