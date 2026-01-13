import 'package:flutter/material.dart';
import 'tablestriper.dart';
import 'columnfilter.dart';
import 'dart:math';


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

  String selectedCategory = 'All';

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
    List<Map<String, String>> filteredRows = selectedCategory == 'All'
        ? allRows
        : ColumnFilter.filter(
            rows: allRows,
            column: 'category',
            allowedValues: [selectedCategory],
          );

    final dropdownCategories = ['All', ...categories];

    return Scaffold(
      appBar: AppBar(title: const Text('Example Table with Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
              items: dropdownCategories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRows.length,
              itemBuilder: (context, index) {
                final row = filteredRows[index];
                return TableStriper(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 50, child: Text('${index + 1}')),
                        Expanded(child: Text(row['word']!)),
                        Expanded(child: Text(row['category']!)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}