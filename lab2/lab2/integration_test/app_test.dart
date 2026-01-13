// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:github_trending_lab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Start app, choose language and open repo detail',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Vänta på dropdown och lista
    final languageDropdown = find.byKey(const Key('languageDropdown'));
    expect(languageDropdown, findsOneWidget);

    // Öppna dropdown och välj ett språk (Dart finns som default - välj en annan för att se uppdatering)
    await tester.tap(languageDropdown);
    await tester.pumpAndSettle();

    // Välj 'JavaScript' om finns i listan
    final javascriptItem = find.text('JavaScript').last;
    await tester.tap(javascriptItem);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Vänta på att repo-listan uppdateras
    final repoList = find.byKey(const Key('repoList'));
    expect(repoList, findsOneWidget);

    // Vänta tills listan har minst en element (kan ta tid beroende på nätverk)
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final firstRepo = find.byKey(const Key('repo_0'));
    expect(firstRepo,
        findsWidgets); // kan vara one or more widgets (ListTile + ink response)

    // Tryck på första repo (om finns)
    await tester.tap(firstRepo.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Kontrollera att detaljvyn öppnades
    final detailKey = find.byKey(const Key('repoDetail'));
    expect(detailKey, findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
