// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinity/main.dart';

void main() {
  testWidgets('App initializes with navbar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrinityApp(), duration: Duration(seconds: 5));

    await tester.pump(Duration(seconds: 5));

    // Verify that our navigation bar is present
    expect(find.byType(Text), findsOneWidget);
  });
}
