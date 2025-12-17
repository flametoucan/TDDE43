import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2_2/main.dart';
import 'package:http/http.dart' as http;

class FakeClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final sampleResponse = {
      "items": [
        {
          "name": "TestRepo",
          "full_name": "User/TestRepo",
          "description": "Test description",
          "stargazers_count": 42,
          "forks_count": 10,
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2024-01-02T00:00:00Z",
          "homepage": "https://example.com",
          "language": "Python",
        },
      ],
    };

    final response = http.Response(jsonEncode(sampleResponse), 200);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  testWidgets('Dropdown and list load correctly', (WidgetTester tester) async {
    final fakeClient = FakeClient();

    await tester.pumpWidget(NetTest(httpClient: fakeClient));

    expect(find.byType(DropdownButtonFormField), findsOneWidget);
    expect(find.text('Git list'), findsOneWidget);

    expect(find.byType(itemCard), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('TestRepo'), findsOneWidget);
    expect(find.text('Test description'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();

    expect(find.text('Python'), findsOneWidget);
  });
}
