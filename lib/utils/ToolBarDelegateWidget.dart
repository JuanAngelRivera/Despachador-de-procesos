import 'package:flutter/material.dart';

class ToolbarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  ToolbarDelegate(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: child,
    );
  }

  @override
  double get maxExtent => 110;
  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
