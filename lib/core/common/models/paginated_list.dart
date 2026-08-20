import 'package:equatable/equatable.dart';

class PaginatedList<T> extends Equatable {
  final List<T> items;
  final int total;
  final int currentPage;
  final int perPage;
  final int lastPage;

  const PaginatedList({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
  });

  @override
  List<Object?> get props => [items, total, currentPage, perPage, lastPage];
}
