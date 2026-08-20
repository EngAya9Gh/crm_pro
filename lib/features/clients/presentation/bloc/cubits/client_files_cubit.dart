import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_file.dart';
import 'package:crm_wakeel/features/clients/domain/usecases/get_client_files_usecase.dart';

// States
abstract class ClientFilesState extends Equatable {
  const ClientFilesState();
  @override
  List<Object?> get props => [];
}

class ClientFilesInitial extends ClientFilesState {}

class ClientFilesLoading extends ClientFilesState {}

class ClientFilesLoaded extends ClientFilesState {
  final List<ClientFile> files;
  const ClientFilesLoaded(this.files);
  @override
  List<Object?> get props => [files];
}

class ClientFilesError extends ClientFilesState {
  final String message;
  const ClientFilesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ClientFilesCubit extends Cubit<ClientFilesState> {
  final GetClientFilesUseCase getClientFiles;

  ClientFilesCubit(this.getClientFiles) : super(ClientFilesInitial());

  Future<void> loadFiles(String clientId) async {
    emit(ClientFilesLoading());
    final result = await getClientFiles(clientId);

    if (isClosed) return;

    result.fold(
      (failure) => emit(ClientFilesError(failure.message)),
      (files) => emit(ClientFilesLoaded(files)),
    );
  }

  // Helper to reload without emitting loading if desired, or just re-use loadFiles
  Future<void> refreshFiles(String clientId) async {
    // If we want to keep showing current files while loading new ones, we can handle that.
    // For now, simple reload.
    await loadFiles(clientId);
  }
}
