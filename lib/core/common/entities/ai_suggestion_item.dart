class AiSuggestionItem {
  final String id;
  final String question;
  final String prompt;
  final String icon;
  final String? action;
  final String? threadId;

  AiSuggestionItem({
    required this.id,
    required this.question,
    required this.prompt,
    required this.icon,
    this.action,
    this.threadId,
  });
}
