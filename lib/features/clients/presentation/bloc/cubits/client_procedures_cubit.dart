import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/client_procedure.dart';
import '../../../domain/usecases/get_client_procedures_usecase.dart';
import '../../../domain/usecases/add_procedure_usecase.dart';
import '../../../domain/usecases/update_procedure_usecase.dart';
import '../../../domain/usecases/delete_procedure_usecase.dart';

part 'client_procedures_state.dart';

class ClientProceduresCubit extends Cubit<ClientProceduresState> {
  final GetClientProceduresUseCase getClientProcedures;
  final AddProcedureUseCase addProcedure;
  final UpdateProcedureUseCase updateProcedure;
  final DeleteProcedureUseCase deleteProcedure;

  ClientProceduresCubit({
    required this.getClientProcedures,
    required this.addProcedure,
    required this.updateProcedure,
    required this.deleteProcedure,
  }) : super(ClientProceduresInitial());

  Future<void> loadProcedures(String clientId) async {
    emit(ClientProceduresLoading());
    final result = await getClientProcedures(clientId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ClientProceduresError(failure.message)),
      (procedures) => emit(ClientProceduresLoaded(procedures)),
    );
  }

  Future<void> addNewProcedure(
    String clientId,
    ClientProcedure procedure,
  ) async {
    // Optimistic update or reload? Let's reload for simplicity and correctness first.
    // Or we can emit loading, then add, then reload.
    // Ideally, we keep the current list, show loading indicator, add, then update list.

    // For now, simpler approach:
    final currentState = state;
    if (currentState is ClientProceduresLoaded) {
      // Optional: Show loading overlay or handled in UI.
      // If we emit Loading, the list disappears. Better to keep loaded state but maybe set a property 'isSubmitting'.
      // But to keep it simple with standard states:
      emit(ClientProceduresLoading());
    }

    final result = await addProcedure(clientId, procedure);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ClientProceduresError(failure.message)),
      (_) => loadProcedures(clientId),
    );
  }

  Future<void> updateExistingProcedure(
    String clientId,
    ClientProcedure procedure,
  ) async {
    emit(ClientProceduresLoading());
    final result = await updateProcedure(clientId, procedure);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ClientProceduresError(failure.message)),
      (_) => loadProcedures(clientId),
    );
  }

  Future<void> deleteExistingProcedure(String clientId, int procedureId) async {
    emit(ClientProceduresLoading());
    final result = await deleteProcedure(clientId, procedureId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ClientProceduresError(failure.message)),
      (_) => loadProcedures(clientId),
    );
  }
}
