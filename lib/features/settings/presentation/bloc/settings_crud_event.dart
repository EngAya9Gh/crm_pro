import 'package:equatable/equatable.dart';

abstract class SettingsCrudEvent extends Equatable {
  const SettingsCrudEvent();
  @override
  List<Object?> get props => [];
}

// --- Teams ---
class CreateTeamEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateTeamEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateTeamEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateTeamEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteTeamEvent extends SettingsCrudEvent {
  final int id;
  const DeleteTeamEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Roles ---
class CreateRoleEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateRoleEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateRoleEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateRoleEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteRoleEvent extends SettingsCrudEvent {
  final int id;
  const DeleteRoleEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Statuses ---
class CreateStatusEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateStatusEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateStatusEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateStatusEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteStatusEvent extends SettingsCrudEvent {
  final int id;
  const DeleteStatusEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Sources ---
class CreateSourceEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateSourceEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateSourceEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateSourceEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteSourceEvent extends SettingsCrudEvent {
  final int id;
  const DeleteSourceEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Behaviors ---
class CreateBehaviorEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateBehaviorEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateBehaviorEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateBehaviorEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteBehaviorEvent extends SettingsCrudEvent {
  final int id;
  const DeleteBehaviorEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Invalid Reasons ---
class CreateInvalidReasonEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateInvalidReasonEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateInvalidReasonEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateInvalidReasonEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteInvalidReasonEvent extends SettingsCrudEvent {
  final int id;
  const DeleteInvalidReasonEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Tags ---
class CreateTagEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateTagEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateTagEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateTagEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteTagEvent extends SettingsCrudEvent {
  final int id;
  const DeleteTagEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Products ---
class CreateProductEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateProductEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateProductEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateProductEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteProductEvent extends SettingsCrudEvent {
  final int id;
  const DeleteProductEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Invoice Tags ---
class CreateInvoiceTagEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateInvoiceTagEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateInvoiceTagEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateInvoiceTagEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteInvoiceTagEvent extends SettingsCrudEvent {
  final int id;
  const DeleteInvoiceTagEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Comment Types ---
class CreateCommentTypeEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateCommentTypeEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateCommentTypeEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateCommentTypeEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteCommentTypeEvent extends SettingsCrudEvent {
  final int id;
  const DeleteCommentTypeEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Regions ---
class CreateRegionEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateRegionEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateRegionEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateRegionEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteRegionEvent extends SettingsCrudEvent {
  final int id;
  const DeleteRegionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Cities ---
class CreateCityEvent extends SettingsCrudEvent {
  final Map<String, dynamic> data;
  const CreateCityEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateCityEvent extends SettingsCrudEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateCityEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteCityEvent extends SettingsCrudEvent {
  final int id;
  const DeleteCityEvent(this.id);
  @override
  List<Object?> get props => [id];
}
