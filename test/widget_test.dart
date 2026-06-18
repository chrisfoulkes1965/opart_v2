import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/app_shell.dart';

void main() {
  testWidgets('app shell shows home title and bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AppShell()),
    );
    await tester.pumpAndSettle();

    expect(find.text('OpArt Lab'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
