class TicketCategory {
  final int id;
  final String name;
  final int? parentId;
  final String? color;
  final String? icon;
  final int? slaHours;
  final bool isActive;
  final List<TicketCategory>? children;

  TicketCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.color,
    this.icon,
    this.slaHours,
    this.isActive = true,
    this.children,
  });
}
