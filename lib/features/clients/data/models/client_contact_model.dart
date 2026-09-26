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
    int parsedId = 0;
    if (json['id'] != null) {
      if (json['id'] is int) parsedId = json['id'];
      else if (json['id'] is String) parsedId = int.tryParse(json['id']) ?? 0;
    }

    bool parsedIsPrimary = false;
    if (json['is_primary'] != null) {
      if (json['is_primary'] is bool) {
        parsedIsPrimary = json['is_primary'];
      } else if (json['is_primary'] is int) {
        parsedIsPrimary = json['is_primary'] == 1;
      } else if (json['is_primary'] is String) {
        parsedIsPrimary = json['is_primary'] == '1' || json['is_primary'] == 'true';
      }
    }

    return ClientContactModel(
      id: parsedId,
      clientId: json['client_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'غير معروف',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      position: json['position']?.toString(),
      isPrimary: parsedIsPrimary,
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
