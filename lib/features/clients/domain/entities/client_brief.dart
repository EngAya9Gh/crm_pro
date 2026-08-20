import 'package:equatable/equatable.dart';

class ClientBrief extends Equatable {
  final int id;
  final String name;

  const ClientBrief({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
