import 'ai_suggestion_item.dart';

class AiSuggestions {
  final List<AiSuggestionItem> general;
  final List<AiSuggestionItem> clientSpecific;

  AiSuggestions({
    required this.general,
    required this.clientSpecific,
  });
}
