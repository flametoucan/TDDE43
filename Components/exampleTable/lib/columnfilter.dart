import 'package:flutter/material.dart';

class ColumnFilter extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const ColumnFilter({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selected,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
      ),
    );
  }
}