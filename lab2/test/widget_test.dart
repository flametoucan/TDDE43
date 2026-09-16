import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Import your app file here (e.g., import 'package:my_app/main.dart';)

void main() {
  testWidgets('Selecting language updates list with repository results', (WidgetTester tester) async {
    // Mock HTTP Client response matching GitHub REST API response structure
    final mockHttpClient = MockClient((request) async {
      return http.Response(
        '''
        {
          "items": [
            {
              "name": "flutter-test-repo",
              "full_name": "flutter/flutter-test-repo",
              "stargazers_count": 1250,
              "description": "Mocked test repository",
              "forks_count": 300,
              "created_at": "2024-02-01T00:00:00Z",
              "updated_at": "2024-03-01T00:00:00Z",
              "homepage": null,
              "language": "Dart"
            }
          ]
        }
        ''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    // 1. Start App with mock client
    await tester.pumpWidget(NetTest(httpClient: mockHttpClient));
    await tester.pumpAndSettle();

    // 2. Simulate User Interaction: Tap dropdown and select 'Dart'
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    expect(dropdownFinder, findsOneWidget);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final optionFinder = find.text('Dart').last;
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();

    // 3. Verify Results: Ensure mocked item appears on screen
    expect(find.text('flutter-test-repo'), findsOneWidget);
    expect(find.text('Mocked test repository'), findsOneWidget);
  });
}