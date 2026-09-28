import 'package:flutter/material.dart';
import 'columnfilter.dart';
import 'tablerow.dart';

class FilterableTable extends StatefulWidget {
  final List<Map<String, String>> rows;
  final List<String> categories;

  const FilterableTable({
    super.key,
    required this.rows,
    required this.categories,
  });

  @override
  State<FilterableTable> createState() => _FilterableTableState();
}

class _FilterableTableState extends State<FilterableTable> {
  static const _all = 'All';
  String _selected = _all;

  @override
  Widget build(BuildContext context) {
    final visible = _selected == _all
        ? widget.rows
        : widget.rows.where((r) => r['category'] == _selected).toList();

    return Column(
      children: [
        ColumnFilter(
          options: [_all, ...widget.categories],
          selected: _selected,
          onChanged: (v) => setState(() => _selected = v),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, i) => WordRow(
              index: i,
              word: visible[i]['word']!,
              category: visible[i]['category']!,
            ),
          ),
        ),
      ],
    );
  }
}