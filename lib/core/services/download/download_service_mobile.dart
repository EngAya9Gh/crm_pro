import 'dart:io';
import 'dart:typed_data';

void downloadFile(Uint8List bytes, String fileName, String? savePath) {
  if (savePath != null) {
    final file = File(savePath);
    file.writeAsBytesSync(bytes);
  } else {
    // If no path provided, we can't save on File System easily without path_provider here.
    // But usually we pass savePath.
    throw ArgumentError('savePath must be provided on Mobile/Desktop');
  }
}
