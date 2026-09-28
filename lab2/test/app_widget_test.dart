import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2_2/main.dart';
import 'helpers/mock_github_client.dart';

void main() {
  testWidgets('Dropdown and list load correctly', (WidgetTester tester) async {
    final requests = <Uri>[];
    final client = mockGithubClient(requests: requests);

    // Pumpa widgeten och vänta tills layout och asynkrona operationer är klara
    await tester.pumpWidget(NetTest(httpClient: client));
    await tester.pumpAndSettle();

    // Kontrollera att DropdownButtonFormField finns
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Kontrollera att AppBar-titel finns
    expect(find.text('Git list'), findsOneWidget);

    expect(find.byType(ItemCard), findsOneWidget);

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

    // Verify the app actually re-fetched with the new language
    expect(requests.last.toString(), contains('language:Python'));
  });

  // ---- New tests start here ----

  testWidgets('Shows an error message when GitHub returns an error',
      (WidgetTester tester) async {
    final client = mockGithubClient(
      statusCode: 403,
      body: {'message': 'API rate limit exceeded'},
    );

    await tester.pumpWidget(NetTest(httpClient: client));
    await tester.pumpAndSettle();

    expect(find.textContaining('API rate limit exceeded'), findsOneWidget);
    expect(find.byType(ItemCard), findsNothing);
  });

  testWidgets('Shows no cards when GitHub returns no repositories',
      (WidgetTester tester) async {
    final client = mockGithubClient(body: {'items': []});

    await tester.pumpWidget(NetTest(httpClient: client));
    await tester.pumpAndSettle();

    expect(find.byType(ItemCard), findsNothing);
    expect(find.textContaining('Hol up'), findsNothing); // loading text gone
  });

  testWidgets('Tapping a card opens the detail screen',
      (WidgetTester tester) async {
    final client = mockGithubClient();

    await tester.pumpWidget(NetTest(httpClient: client));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ItemCard));
    await tester.pumpAndSettle();

    expect(find.byType(DetailedScreen), findsOneWidget);
    expect(find.text('Full Name: User/TestRepo'), findsOneWidget);
    expect(find.text('Stars: 42'), findsOneWidget);
  });
}