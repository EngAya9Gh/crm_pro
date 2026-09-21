import '../../domain/entities/ai_suggestions.dart';

class AiSuggestionsModel extends AiSuggestions {
  AiSuggestionsModel({
    required super.general,
    required super.clientSpecific,
  });

  factory AiSuggestionsModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionsModel(
      general: json['general'] != null ? List<String>.from(json['general']) : [],
      clientSpecific: json['client_specific'] != null ? List<String>.from(json['client_specific']) : [],
    );
  }
}
