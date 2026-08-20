import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final bool isRefresh;
  const LoadDashboardData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}
