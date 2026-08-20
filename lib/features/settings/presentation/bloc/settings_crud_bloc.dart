import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/settings_usecases.dart';
import 'settings_crud_event.dart';
import 'settings_crud_state.dart';

class SettingsCrudBloc extends Bloc<SettingsCrudEvent, SettingsCrudState> {
  // Teams
  final CreateTeamUseCase createTeam;
  final UpdateTeamUseCase updateTeam;
  final DeleteTeamUseCase deleteTeam;

  // Roles
  final CreateRoleUseCase createRole;
  final UpdateRoleUseCase updateRole;
  final DeleteRoleUseCase deleteRole;

  // Statuses
  final CreateClientStatusUseCase createStatus;
  final UpdateClientStatusUseCase updateStatus;
  final DeleteClientStatusUseCase deleteStatus;

  // Sources
  final CreateSourceUseCase createSource;
  final UpdateSourceUseCase updateSource;
  final DeleteSourceUseCase deleteSource;

  // Behaviors
  final CreateBehaviorUseCase createBehavior;
  final UpdateBehaviorUseCase updateBehavior;
  final DeleteBehaviorUseCase deleteBehavior;

  // Invalid Reasons
  final CreateInvalidReasonUseCase createInvalidReason;
  final UpdateInvalidReasonUseCase updateInvalidReason;
  final DeleteInvalidReasonUseCase deleteInvalidReason;

  // Tags
  final CreateClientTagUseCase createTag;
  final UpdateClientTagUseCase updateTag;
  final DeleteClientTagUseCase deleteTag;

  // Products (Added these)
  final CreateProductUseCase createProduct;
  final UpdateProductUseCase updateProduct;
  final DeleteProductUseCase deleteProduct;

  // Invoice Tags
  final CreateInvoiceTagUseCase createInvoiceTag;
  final UpdateInvoiceTagUseCase updateInvoiceTag;
  final DeleteInvoiceTagUseCase deleteInvoiceTag;

  // Comment Types
  final CreateCommentTypeUseCase createCommentType;
  final UpdateCommentTypeUseCase updateCommentType;
  final DeleteCommentTypeUseCase deleteCommentType;

  // Regions
  final CreateRegionUseCase createRegion;
  final UpdateRegionUseCase updateRegion;
  final DeleteRegionUseCase deleteRegion;

  // Cities
  final CreateCityUseCase createCity;
  final UpdateCityUseCase updateCity;
  final DeleteCityUseCase deleteCity;

  SettingsCrudBloc({
    required this.createTeam,
    required this.updateTeam,
    required this.deleteTeam,
    required this.createRole,
    required this.updateRole,
    required this.deleteRole,
    required this.createStatus,
    required this.updateStatus,
    required this.deleteStatus,
    required this.createSource,
    required this.updateSource,
    required this.deleteSource,
    required this.createBehavior,
    required this.updateBehavior,
    required this.deleteBehavior,
    required this.createInvalidReason,
    required this.updateInvalidReason,
    required this.deleteInvalidReason,
    required this.createTag,
    required this.updateTag,
    required this.deleteTag,
    required this.createProduct, // Added
    required this.updateProduct, // Added
    required this.deleteProduct, // Added
    required this.createInvoiceTag,
    required this.updateInvoiceTag,
    required this.deleteInvoiceTag,
    required this.createCommentType,
    required this.updateCommentType,
    required this.deleteCommentType,
    required this.createRegion,
    required this.updateRegion,
    required this.deleteRegion,
    required this.createCity,
    required this.updateCity,
    required this.deleteCity,
  }) : super(SettingsCrudInitial()) {
    // Teams
    on<CreateTeamEvent>(_onCreateTeam);
    on<UpdateTeamEvent>(_onUpdateTeam);
    on<DeleteTeamEvent>(_onDeleteTeam);

    // Roles
    on<CreateRoleEvent>(_onCreateRole);
    on<UpdateRoleEvent>(_onUpdateRole);
    on<DeleteRoleEvent>(_onDeleteRole);

    // Statuses
    on<CreateStatusEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createStatus(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة الحالة بنجاح')),
      );
    });
    on<UpdateStatusEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateStatus(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث الحالة بنجاح')),
      );
    });
    on<DeleteStatusEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteStatus(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف الحالة بنجاح')),
      );
    });

    // Sources
    on<CreateSourceEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createSource(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة المصدر بنجاح')),
      );
    });
    on<UpdateSourceEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateSource(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث المصدر بنجاح')),
      );
    });
    on<DeleteSourceEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteSource(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف المصدر بنجاح')),
      );
    });

    // Behaviors
    on<CreateBehaviorEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createBehavior(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة السلوك بنجاح')),
      );
    });
    on<UpdateBehaviorEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateBehavior(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث السلوك بنجاح')),
      );
    });
    on<DeleteBehaviorEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteBehavior(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف السلوك بنجاح')),
      );
    });

    // Invalid Reasons
    on<CreateInvalidReasonEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createInvalidReason(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة سبب الاستبعاد بنجاح')),
      );
    });
    on<UpdateInvalidReasonEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateInvalidReason(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث سبب الاستبعاد بنجاح')),
      );
    });
    on<DeleteInvalidReasonEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteInvalidReason(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف سبب الاستبعاد بنجاح')),
      );
    });

    // Tags
    on<CreateTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createTag(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة الوسم بنجاح')),
      );
    });
    on<UpdateTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateTag(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث الوسم بنجاح')),
      );
    });
    on<DeleteTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteTag(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف الوسم بنجاح')),
      );
    });

    // Products (Added handlers)
    on<CreateProductEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createProduct(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة المنتج بنجاح')),
      );
    });
    on<UpdateProductEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateProduct(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث المنتج بنجاح')),
      );
    });
    on<DeleteProductEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteProduct(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف المنتج بنجاح')),
      );
    });

    // Invoice Tags
    on<CreateInvoiceTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createInvoiceTag(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة وسم الفاتورة بنجاح')),
      );
    });
    on<UpdateInvoiceTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateInvoiceTag(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث وسم الفاتورة بنجاح')),
      );
    });
    on<DeleteInvoiceTagEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteInvoiceTag(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف وسم الفاتورة بنجاح')),
      );
    });

    // Comment Types
    on<CreateCommentTypeEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createCommentType(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة نوع التعليق بنجاح')),
      );
    });
    on<UpdateCommentTypeEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateCommentType(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث نوع التعليق بنجاح')),
      );
    });
    on<DeleteCommentTypeEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteCommentType(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف نوع التعليق بنجاح')),
      );
    });

    // Regions
    on<CreateRegionEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createRegion(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة المنطقة بنجاح')),
      );
    });
    on<UpdateRegionEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateRegion(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث المنطقة بنجاح')),
      );
    });
    on<DeleteRegionEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteRegion(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف المنطقة بنجاح')),
      );
    });

    // Cities
    on<CreateCityEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await createCity(event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم إضافة المدينة بنجاح')),
      );
    });
    on<UpdateCityEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await updateCity(event.id, event.data);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم تحديث المدينة بنجاح')),
      );
    });
    on<DeleteCityEvent>((event, emit) async {
      emit(SettingsCrudLoading());
      final result = await deleteCity(event.id);
      result.fold(
        (failure) => emit(SettingsCrudFailure(failure.message)),
        (_) => emit(const SettingsCrudSuccess('تم حذف المدينة بنجاح')),
      );
    });
  }

  // --- Teams Handlers ---
  Future<void> _onCreateTeam(
    CreateTeamEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await createTeam(event.data);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم إنشاء الفريق بنجاح')),
    );
  }

  Future<void> _onUpdateTeam(
    UpdateTeamEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await updateTeam(event.id, event.data);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم تحديث الفريق بنجاح')),
    );
  }

  Future<void> _onDeleteTeam(
    DeleteTeamEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await deleteTeam(event.id);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم حذف الفريق بنجاح')),
    );
  }

  // --- Roles Handlers ---
  Future<void> _onCreateRole(
    CreateRoleEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await createRole(event.data);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم إنشاء الدور بنجاح')),
    );
  }

  Future<void> _onUpdateRole(
    UpdateRoleEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await updateRole(event.id, event.data);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم تحديث الدور بنجاح')),
    );
  }

  Future<void> _onDeleteRole(
    DeleteRoleEvent event,
    Emitter<SettingsCrudState> emit,
  ) async {
    emit(SettingsCrudLoading());
    final result = await deleteRole(event.id);
    result.fold(
      (failure) => emit(SettingsCrudFailure(failure.message)),
      (_) => emit(const SettingsCrudSuccess('تم حذف الدور بنجاح')),
    );
  }
}
