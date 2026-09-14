import 'dart:convert';
import 'lib/features/users/data/models/user_model.dart';

void main() {
  final jsonString = '''{
    "id": 6,
    "name": "Miss Madaline Lehner",
    "email": "reva.funk@example.net",
    "phone": "0530401799",
    "avatar": null,
    "is_active": true,
    "permissions_list": ["clients.view"],
    "team": {"id": 1, "name": "Sales"},
    "role": {"id": 3, "name": "Sales Rep"}
  }''';

  try {
    final map = jsonDecode(jsonString);
    final user = UserModel.fromJson(map);
    print('Success: ${user.name}');
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
