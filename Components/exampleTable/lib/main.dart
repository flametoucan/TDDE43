import 'package:flutter/material.dart';
import 'dart:math';
import 'filterabletable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleTable(rowCount: 25),
    );
  }
}

class ExampleTable extends StatefulWidget {
  final int rowCount;

  const ExampleTable({super.key, required this.rowCount});

  @override
  State<ExampleTable> createState() => _ExampleTableState();
}

class _ExampleTableState extends State<ExampleTable> {
  final List<String> words = const [
    'Äpple',
    'Banan',
    'Citron',
    'Dator',
    'Mus',
    'Tangentbord',
    'Hund',
    'Katt',
    'Fågel',
    'Bil',
  ];

  final List<String> categories = const [
    'Frukt',
    'Teknik',
    'Djur',
    'Fordon',
  ];

  late List<Map<String, String>> allRows;

  @override
  void initState() {
    super.initState();
    final random = Random();
    allRows = List.generate(widget.rowCount, (index) {
      return {
        'word': words[random.nextInt(words.length)],
        'category': categories[random.nextInt(categories.length)],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Table with Filter')),
      body: FilterableTable(rows: allRows, categories: categories),
    );
  }
}