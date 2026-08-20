import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_threads_usecase.dart';
import 'whatsapp_threads_state.dart';

class WhatsappThreadsCubit extends Cubit<WhatsappThreadsState> {
  final GetWhatsappThreadsUseCase getThreadsUseCase;
  bool _isFetching = false;

  WhatsappThreadsCubit({required this.getThreadsUseCase})
      : super(WhatsappThreadsInitial());

  Future<void> loadThreads({bool refresh = false}) async {
    if (_isFetching || state is WhatsappThreadsLoading) return;
    _isFetching = true;

    int page = 1;
    List<dynamic> currentThreads = [];

    if (!refresh && state is WhatsappThreadsLoaded) {
      final currentState = state as WhatsappThreadsLoaded;
      if (currentState.hasReachedMax) return;
      page = currentState.currentPage + 1;
      currentThreads = currentState.threads;
    } else {
      emit(WhatsappThreadsLoading());
    }

    final result = await getThreadsUseCase(page: page);
    _isFetching = false;

    result.fold(
      (failure) => emit(WhatsappThreadsError(failure.message)),
      (threads) {
        if (threads.isEmpty) {
          emit(WhatsappThreadsLoaded(
            threads: List.from(currentThreads),
            hasReachedMax: true,
            currentPage: page,
          ));
        } else {
          emit(WhatsappThreadsLoaded(
            threads: List.from(currentThreads)..addAll(threads),
            hasReachedMax: threads.length < 10,
            currentPage: page,
          ));
        }
      },
    );
  }
}
