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

    // Pumpa widgeten och vänta tills layout och asynkrona operationer är klara
    await tester.pumpWidget(NetTest(httpClient: fakeClient));
    await tester.pumpAndSettle();

    // Kontrollera att DropdownButtonFormField finns
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Kontrollera att AppBar-titel finns
    expect(find.text('Git list'), findsOneWidget);
    
    expect(find.byType(ItemCard), findsOneWidget);

    // Vänta på att FutureBuilder laddar data
    await tester.pumpAndSettle();

    // Kontrollera att fake repository visas korrekt
    expect(find.text('TestRepo'), findsOneWidget);
    expect(find.text('Test description'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Öppna dropdownen och välj Python
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();

    // Kontrollera att dropdownen visar det valda värdet
    expect(find.text('Python'), findsOneWidget);
  });
}
