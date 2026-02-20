import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealtime_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mealtime_app/l10n/app_localizations.dart';

void main() {
  group('NotificationsPage', () {
    Widget buildTestWidget() {
      return MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NotificationsPage(),
      );
    }

    testWidgets('exibe app bar com título de notificações', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('exibe loading inicial ou estado de erro após um frame',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasErrorIcon = find.byIcon(Icons.error_outline).evaluate().isNotEmpty;
      final hasEmptyIcon =
          find.byIcon(Icons.notifications_none).evaluate().isNotEmpty;
      final hasTryAgain = find.text('Tentar novamente').evaluate().isNotEmpty;
      final hasEmptyTitle = find.text('Nenhuma notificação').evaluate().isNotEmpty;

      expect(hasScaffold, true);
      expect(
        hasLoading || hasErrorIcon || hasEmptyIcon || hasTryAgain || hasEmptyTitle,
        true,
        reason: 'Deve exibir loading, erro ou estado vazio',
      );
    });
  });
}
