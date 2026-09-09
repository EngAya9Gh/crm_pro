import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/integrations_entity.dart';
import '../repositories/settings_repository.dart';

class GetIntegrationsUseCase {
  final SettingsRepository repository;

  GetIntegrationsUseCase(this.repository);

  Future<Either<Failure, IntegrationsEntity>> call() async {
    return await repository.getIntegrations();
  }
}
