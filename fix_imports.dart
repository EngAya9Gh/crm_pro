import 'dart:io';

void main() {
  final dir = Directory('lib');
  final entitiesOld = "features/client_ai/domain/entities";
  final entitiesNew = "core/common/entities";
  final modelsOld = "features/client_ai/data/models";
  final modelsNew = "core/common/models";

  final entitiesFiles = ['ai_session.dart', 'ai_message.dart', 'ai_suggestions.dart'];
  final modelsFiles = ['ai_session_model.dart', 'ai_message_model.dart', 'ai_suggestions_model.dart'];

  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = file.readAsStringSync();
      bool changed = false;

      for (final f in entitiesFiles) {
        if (content.contains(f)) {
          // Replace relative paths
          content = content.replaceAll(
            RegExp(r"['""](\.\./)+domain/entities/" + f + r"['""]"),
            "'package:crm_wakeel/core/common/entities/" + f + "'"
          );
          // Just in case it was '../entities'
          content = content.replaceAll(
            RegExp(r"['""](\.\./)+entities/" + f + r"['""]"),
            "'package:crm_wakeel/core/common/entities/" + f + "'"
          );
          changed = true;
        }
      }

      for (final f in modelsFiles) {
        if (content.contains(f)) {
          content = content.replaceAll(
            RegExp(r"['""](\.\./)+data/models/" + f + r"['""]"),
            "'package:crm_wakeel/core/common/models/" + f + "'"
          );
          content = content.replaceAll(
            RegExp(r"['""](\.\./)+models/" + f + r"['""]"),
            "'package:crm_wakeel/core/common/models/" + f + "'"
          );
          changed = true;
        }
      }

      if (changed) {
        file.writeAsStringSync(content);
        print("Updated ${file.path}");
      }
    }
  }
}
