import 'package:flutter_test/flutter_test.dart';

import 'package:resqnova/main.dart';

void main() {
  testWidgets('ResQNova app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ResQNovaApp(
        loggedIn: false,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ResQNova'), findsOneWidget);
  });
}