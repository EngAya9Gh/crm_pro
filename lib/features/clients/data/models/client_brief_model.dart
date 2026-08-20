import '../../domain/entities/client_brief.dart';

class ClientBriefModel extends ClientBrief {
  const ClientBriefModel({required super.id, required super.name});

  factory ClientBriefModel.fromJson(Map<String, dynamic> json) {
    return ClientBriefModel(id: json['id'], name: json['name']);
  }
}
