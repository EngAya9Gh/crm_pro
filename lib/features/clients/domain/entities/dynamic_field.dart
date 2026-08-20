class DynamicField {
  final String id;
  final String name;
  final String? color;
  final String? icon;
  final int order;
  final bool isActive;

  DynamicField({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    required this.order,
    this.isActive = true,
  });
}
