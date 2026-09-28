import 'package:flutter/material.dart';
import 'tablestriper.dart';

class WordRow extends StatelessWidget {
  final int index;
  final String word;
  final String category;

  const WordRow({
    super.key,
    required this.index,
    required this.word,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return TableStriper(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: 50, child: Text('${index + 1}')),
            Expanded(child: Text(word)),
            Expanded(child: Text(category)),
          ],
        ),
      ),
    );
  }
}