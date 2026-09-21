import 'package:crm_wakeel/core/common/entities/ai_suggestions.dart';

import 'ai_suggestion_item_model.dart';

class AiSuggestionsModel extends AiSuggestions {
  AiSuggestionsModel({
    required super.general,
    required super.clientSpecific,
  });

  factory AiSuggestionsModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionsModel(
      general: json['general'] != null 
          ? (json['general'] as List).map((e) => AiSuggestionItemModel.fromJson(e)).toList() 
          : [],
      clientSpecific: json['client_specific'] != null 
          ? (json['client_specific'] as List).map((e) => AiSuggestionItemModel.fromJson(e)).toList() 
          : [],
    );
  }
}
