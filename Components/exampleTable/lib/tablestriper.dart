import 'package:flutter/material.dart';

class TableStriper extends StatelessWidget {
  final int index;
  final Widget child;
  final Color evenColor;
  final Color oddColor;

  const TableStriper({
    super.key,
    required this.index,
    required this.child,
    this.evenColor = Colors.white,
    this.oddColor = const Color(0xFFF0F0F0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isEven ? evenColor : oddColor,
      child: child,
    );
  }
}