import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laba12/screens/first_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../mocks.mocks.dart';
import 'mocks.dart';

void main() {
  late MockFirebaseRemoteConfig mockRemoteConfig;

  setUp(() {
    mockRemoteConfig = MockFirebaseRemoteConfig();

    // Настройка моков для Firebase
    when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async => true);
    when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
    when(mockRemoteConfig.activate()).thenAnswer((_) async => true);
    when(mockRemoteConfig.getBool('add_balance_enabled')).thenReturn(true);
    when(mockRemoteConfig.onConfigUpdated).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Basic render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirstScreen(),
      ),
    );
    expect(find.text('DCOPAY'), findsOneWidget);
  });

  testWidgets('Add balance test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirstScreen(),
      ),
    );
    await tester.tap(find.text('Add 50\$'));
    await tester.pump();
    expect(find.text('1050\$'), findsOneWidget);
  });

  testWidgets('Name input test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirstScreen(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pump();
    expect(find.text('Hello Test,'), findsOneWidget);
  });

  testWidgets('Staggered animation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirstScreen(),
      ),
    );
    await tester.tap(find.text('Show Staggered'));
    await tester.pumpAndSettle();
    expect(find.byType(ActionButton), findsNWidgets(8));
  });

  testWidgets('Card drag test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirstScreen(),
      ),
    );
    final card = find.byType(Draggable).first;
    await tester.drag(card, Offset(50, 0));
    await tester.pumpAndSettle();
    // Проверки после drag
  });
}