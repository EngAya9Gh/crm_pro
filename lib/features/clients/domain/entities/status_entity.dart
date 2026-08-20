import 'package:equatable/equatable.dart';

class StatusEntity extends Equatable {
  final int id;
  final String name;
  final String color;

  const StatusEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}
