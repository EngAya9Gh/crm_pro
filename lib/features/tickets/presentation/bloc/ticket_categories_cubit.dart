import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/tickets_usecases.dart';
import '../../domain/entities/ticket_category.dart';
import 'tickets_state.dart';

class TicketCategoriesCubit extends Cubit<TicketsState> {
  final GetTicketCategoriesUseCase getCategoriesUseCase;
  final CreateTicketCategoryUseCase createCategoryUseCase;
  final UpdateTicketCategoryUseCase updateCategoryUseCase;
  final DeleteTicketCategoryUseCase deleteCategoryUseCase;

  TicketCategoriesCubit({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(TicketsInitial());

  Future<void> getCategories() async {
    emit(TicketsLoading());
    try {
      final categories = await getCategoriesUseCase();
      emit(TicketCategoriesLoaded(categories));
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> createCategory(TicketCategory category) async {
    emit(TicketsLoading());
    try {
      await createCategoryUseCase(category);
      emit(TicketOperationSuccess('تم إضافة التصنيف بنجاح'));
      getCategories();
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> updateCategory(int id, TicketCategory category) async {
    emit(TicketsLoading());
    try {
      await updateCategoryUseCase(id, category);
      emit(TicketOperationSuccess('تم تعديل التصنيف بنجاح'));
      getCategories();
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    emit(TicketsLoading());
    try {
      await deleteCategoryUseCase(id);
      emit(TicketOperationSuccess('تم حذف التصنيف بنجاح'));
      getCategories();
    } catch (e) {
      emit(TicketsError(e.toString()));
    }
  }
}
