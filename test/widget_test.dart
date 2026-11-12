// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fristapp/main.dart';

void main() {
  testWidgets('calculates an expression and adds it to history', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    for (final key in ['7', '+', '5', '=']) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }

    expect(find.text('12'), findsOneWidget);
    await tester.tap(find.byTooltip('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('7 + 5 = 12'), findsOneWidget);
  });

  testWidgets('shows a message instead of crashing on division by zero', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (final key in ['1', '÷', '0', '=']) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }
    expect(find.text('Tidak bisa bagi 0'), findsOneWidget);
  });
}
