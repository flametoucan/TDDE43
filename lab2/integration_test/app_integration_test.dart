import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab2_2/main.dart';
import '../test/helpers/mock_github_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dropdown and list load correctly', (WidgetTester tester) async {
    final requests = <Uri>[];
    final client = mockGithubClient(requests: requests);

    await tester.pumpWidget(NetTest(httpClient: client));

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Git list'), findsOneWidget);

    expect(find.byType(ItemCard), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('TestRepo'), findsOneWidget);
    expect(find.text('Test description'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();

    expect(find.text('Python'), findsOneWidget);
    expect(requests.last.toString(), contains('language:Python'));
  });
}
