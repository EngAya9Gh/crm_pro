import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/evaluations_usecases.dart';
import '../../domain/entities/evaluation_type.dart';
import 'evaluations_state.dart';

class EvaluationTypesCubit extends Cubit<EvaluationsState> {
  final GetEvaluationTypesUseCase getTypesUseCase;
  final CreateEvaluationTypeUseCase createTypeUseCase;
  final UpdateEvaluationTypeUseCase updateTypeUseCase;
  final DeleteEvaluationTypeUseCase deleteTypeUseCase;
  List<EvaluationType> types = [];

  EvaluationTypesCubit({
    required this.getTypesUseCase,
    required this.createTypeUseCase,
    required this.updateTypeUseCase,
    required this.deleteTypeUseCase,
  }) : super(EvaluationsInitial());

  Future<void> getTypes() async {
    emit(EvaluationsLoading());
    try {
      types = await getTypesUseCase();
      emit(EvaluationTypesLoaded(types));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> createType(EvaluationType type) async {
    emit(EvaluationsLoading());
    try {
      await createTypeUseCase(type);
      emit(EvaluationOperationSuccess('تم إضافة النوع بنجاح'));
      getTypes();
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> updateType(int id, EvaluationType type) async {
    emit(EvaluationsLoading());
    try {
      await updateTypeUseCase(id, type);
      emit(EvaluationOperationSuccess('تم تعديل النوع بنجاح'));
      getTypes();
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> deleteType(int id) async {
    emit(EvaluationsLoading());
    try {
      await deleteTypeUseCase(id);
      emit(EvaluationOperationSuccess('تم حذف النوع بنجاح'));
      getTypes();
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }
}
