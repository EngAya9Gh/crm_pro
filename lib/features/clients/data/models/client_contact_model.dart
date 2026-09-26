import '../../domain/entities/client_contact.dart';

class ClientContactModel extends ClientContact {
  ClientContactModel({
    required super.id,
    required super.clientId,
    required super.name,
    required super.phone,
    super.email,
    super.position,
    required super.isPrimary,
  });

  factory ClientContactModel.fromJson(Map<String, dynamic> json) {
    return ClientContactModel(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      position: json['position'] as String?,
      isPrimary: (json['is_primary'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'name': name,
      'phone': phone,
      'email': email,
      'position': position,
      'is_primary': isPrimary,
    };
  }
}
