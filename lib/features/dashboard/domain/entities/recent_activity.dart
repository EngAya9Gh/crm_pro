import 'package:equatable/equatable.dart';

class RecentActivity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String type;
  final String createdAt;
  final String? userName;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.userName,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    createdAt,
    userName,
  ];
}
