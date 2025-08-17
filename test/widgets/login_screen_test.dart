import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laba12/providers/auth_provider.dart';
import 'package:laba12/screens/login_screen.dart';
import 'package:laba12/screens/register_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  testWidgets('1. RegisterScreen отрендерился корректно плз', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Already have an account? Login'), findsOneWidget);
  });


  testWidgets('2. Пароли не совпадают :(', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: RegisterScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.enterText(find.byType(TextFormField).at(2), 'password2');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('3. Показ неправльного емаила', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: RegisterScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.enterText(find.byType(TextFormField).at(2), 'password');

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('4. Drag скроллит экран и скрывает клавиатуру', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
          child: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: RegisterScreen(),
          ),
        ),
      ),
    );

    final firstTextField = find.byType(TextFormField).first;
    final registerButton = find.text('Register');
    final scrollView = find.byType(SingleChildScrollView);

    final initialButtonPos = tester.getTopLeft(registerButton);
    debugPrint('Initial button position:  $initialButtonPos');

    await tester.drag(scrollView, Offset(0, 0));
    await tester.pumpAndSettle();

    final newButtonPos = tester.getTopLeft(registerButton);
    debugPrint('New button position: $newButtonPos');

    expect(newButtonPos.dy, lessThan(initialButtonPos.dy));
  });
  testWidgets('5. Навигация', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: RegisterScreen(),
        ),
        routes: {
          '/login': (context) => LoginScreen(),
        },
      ),
    );

    await tester.tap(find.text('Already have an account? Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}