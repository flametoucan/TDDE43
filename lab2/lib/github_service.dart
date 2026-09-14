// lib/github_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/repository.dart';

class GithubService {
  // Optional: sätt en token här för högre rate-limit (eller läs från env).
  final String? githubToken;

  GithubService({this.githubToken});

  // period: "daily", "weekly", "monthly"
  // language: t.ex. "Dart", "JavaScript", "Python"
  Future<List<Repository>> fetchTrending({
    required String language,
    required String period,
    int perPage = 30,
  }) async {
    final since = _sinceDateForPeriod(period);
    // Bygga query: language:LANG created:>YYYY-MM-DD
    final q = 'language:$language created:>$since';
    final uri = Uri.https('api.github.com', '/search/repositories', {
      'q': q,
      'sort': 'stars',
      'order': 'desc',
      'per_page': perPage.toString(),
    });

    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
    };
    if (githubToken != null && githubToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $githubToken';
    }

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('GitHub API error: ${res.statusCode} ${res.body}');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final items = (jsonBody['items'] as List<dynamic>? ?? []);
    return items
        .map((e) => Repository.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _sinceDateForPeriod(String period) {
    final now = DateTime.now().toUtc();
    DateTime from;
    switch (period.toLowerCase()) {
      case 'daily':
        from = now.subtract(Duration(days: 1));
        break;
      case 'weekly':
        from = now.subtract(Duration(days: 7));
        break;
      case 'monthly':
        from = DateTime(now.year, now.month - 1, now.day);
        break;
      default:
        from = now.subtract(Duration(days: 7));
    }
    return '${from.year.toString().padLeft(4, '0')}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
  }
}
