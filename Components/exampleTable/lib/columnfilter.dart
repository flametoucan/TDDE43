class ColumnFilter {
  static List<Map<String, String>> filter({
    required List<Map<String, String>> rows,
    required String column,
    required List<String> allowedValues,
  }) {
    return rows.where((row) {
      final value = row[column];
      return value != null && allowedValues.contains(value);
    }).toList();
  }
}