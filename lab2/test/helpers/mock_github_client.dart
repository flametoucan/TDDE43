import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// One repository, in the same shape GitHub's search API returns.
final Map<String, dynamic> sampleRepo = {
  "name": "TestRepo",
  "full_name": "User/TestRepo",
  "description": "Test description",
  "stargazers_count": 42,
  "forks_count": 10,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-02T00:00:00Z",
  "homepage": "https://example.com",
  "language": "Python",
};

/// Fake HTTP client. Every request gets [statusCode] and [body] back
/// (default: a normal response with one repo). Each request URL is added
/// to [requests] so tests can check what the app actually asked for.
MockClient mockGithubClient({
  List<Uri>? requests,
  int statusCode = 200,
  Map<String, dynamic>? body,
}) {
  return MockClient((request) async {
    requests?.add(request.url);
    return http.Response(
      jsonEncode(body ?? {'items': [sampleRepo]}),
      statusCode,
    );
  });
}