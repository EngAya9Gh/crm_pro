class ClientContact {
  final int id;
  final int clientId;
  final String name;
  final String phone;
  final String? email;
  final String? position;
  final bool isPrimary;

  ClientContact({
    required this.id,
    required this.clientId,
    required this.name,
    required this.phone,
    this.email,
    this.position,
    required this.isPrimary,
  });

  ClientContact copyWith({
    int? id,
    int? clientId,
    String? name,
    String? phone,
    String? email,
    String? position,
    bool? isPrimary,
  }) {
    return ClientContact(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      position: position ?? this.position,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
