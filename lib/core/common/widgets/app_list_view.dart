import 'package:flutter/material.dart';

class AppListView extends StatelessWidget {
  final int? itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final List<Widget>? children;
  final ScrollController? controller;

  const AppListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : itemCount = null, itemBuilder = null, separatorBuilder = null;

  const AppListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : separatorBuilder = null, children = null;

  const AppListView.separated({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required Widget Function(BuildContext, int) separatorBuilder,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : separatorBuilder = separatorBuilder, children = null;

  @override
  Widget build(BuildContext context) {
    if (children != null) {
      return ListView(
        padding: padding,
        physics: physics,
        controller: controller,
        shrinkWrap: shrinkWrap,
        scrollDirection: scrollDirection,
        children: children!,
      );
    }
    if (separatorBuilder != null) {
      return ListView.separated(
        padding: padding,
        physics: physics,
        controller: controller,
        shrinkWrap: shrinkWrap,
        scrollDirection: scrollDirection,
        itemCount: itemCount!,
        itemBuilder: itemBuilder!,
        separatorBuilder: separatorBuilder!,
      );
    }
    return ListView.builder(
      padding: padding,
      physics: physics,
      controller: controller,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      itemCount: itemCount!,
      itemBuilder: itemBuilder!,
    );
  }
}
