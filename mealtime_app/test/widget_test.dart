// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await init();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Mealtime App'), findsOneWidget);
    expect(find.text('Bem-vindo ao Mealtime!'), findsOneWidget);
  });
}
