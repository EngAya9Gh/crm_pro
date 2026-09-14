import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateIntegrationParams {
  final String platform;
  final bool isActive;
  final Map<String, dynamic> credentials;

  UpdateIntegrationParams({
    required this.platform,
    required this.isActive,
    required this.credentials,
  });

  Map<String, dynamic> toJson() {
    return {'is_active': isActive, 'credentials': credentials};
  }
}

class UpdateIntegrationUseCase {
  final SettingsRepository repository;

  UpdateIntegrationUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateIntegrationParams params) async {
    return await repository.updateIntegration(params.platform, params.toJson());
  }
}
