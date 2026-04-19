import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/home_page.dart';

void main() {
  testWidgets('home screen shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MyHomePage(title: 'Op Art Studio')),
    );
    expect(find.text('OpArt Lab'), findsOneWidget);
  });
}
