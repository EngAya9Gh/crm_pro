import '../../domain/entities/client_enums.dart';
import '../../domain/entities/client_file.dart';

class ClientFileModel extends ClientFile {
  ClientFileModel({
    required super.id,
    required super.name,
    required super.type,
    required super.url,
    required super.sizeBytes,
    required super.uploadedAt,
    required super.uploadedBy,
  });

  factory ClientFileModel.fromJson(Map<String, dynamic> json) {
    return ClientFileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: _parseType(json['type']),
      url: json['url'] ?? json['path'] ?? '',
      sizeBytes: json['size_bytes'] ?? json['size'] ?? 0,
      uploadedAt:
          DateTime.tryParse(json['uploaded_at'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      uploadedBy:
          json['uploaded_by'] ?? json['user_id']?.toString() ?? 'System',
    );
  }

  static FileType _parseType(String? value) {
    if (value == null) return FileType.other;
    try {
      return FileType.values.byName(value.toLowerCase());
    } catch (_) {
      return FileType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'url': url,
      'size_bytes': sizeBytes,
      'uploaded_at': uploadedAt.toIso8601String(),
      'uploaded_by': uploadedBy,
    };
  }
}
