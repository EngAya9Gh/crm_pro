import 'dart:typed_data';
import 'download_service_stub.dart'
    if (dart.library.html) 'download_service_web.dart'
    if (dart.library.io) 'download_service_mobile.dart';

class DownloadService {
  static void download({
    required Uint8List bytes,
    required String fileName,
    String? savePath,
  }) {
    downloadFile(bytes, fileName, savePath);
  }
}
