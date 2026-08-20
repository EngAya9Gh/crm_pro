import 'client_enums.dart';

class ClientFile {
  final String id;
  final String name;
  final FileType type;
  final String url;
  final int sizeBytes;
  final DateTime uploadedAt;
  final String uploadedBy;

  ClientFile({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.sizeBytes,
    required this.uploadedAt,
    required this.uploadedBy,
  });
}
