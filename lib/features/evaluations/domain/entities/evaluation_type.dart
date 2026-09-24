class EvaluationType {
  final int id;
  final String name;
  final bool isActive;

  EvaluationType({
    required this.id,
    required this.name,
    this.isActive = true,
  });
}
