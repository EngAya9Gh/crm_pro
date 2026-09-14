import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_integrations_usecase.dart';
import '../../../domain/usecases/update_integrations_usecase.dart';
import 'integrations_state.dart';

class IntegrationsCubit extends Cubit<IntegrationsState> {
  final GetIntegrationsUseCase getIntegrationsUseCase;
  final UpdateIntegrationUseCase updateIntegrationUseCase;

  IntegrationsCubit({
    required this.getIntegrationsUseCase,
    required this.updateIntegrationUseCase,
  }) : super(IntegrationsInitial());

  Future<void> loadIntegrations() async {
    emit(IntegrationsLoading());
    final result = await getIntegrationsUseCase();

    result.fold(
      (failure) => emit(IntegrationsError(failure.message)),
      (data) => emit(IntegrationsLoaded(data)),
    );
  }

  Future<void> updateIntegration({
    required String platform,
    required bool isActive,
    required Map<String, dynamic> credentials,
  }) async {
    final currentState = state;

    emit(IntegrationUpdateLoading());

    final params = UpdateIntegrationParams(
      platform: platform,
      isActive: isActive,
      credentials: credentials,
    );

    final result = await updateIntegrationUseCase(params);

    result.fold(
      (failure) {
        emit(IntegrationUpdateError(failure.message));
        if (currentState is IntegrationsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const IntegrationUpdateSuccess('تم تحديث الإعدادات بنجاح'));
        loadIntegrations();
      },
    );
  }
}
