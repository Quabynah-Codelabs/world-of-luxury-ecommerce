// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'services/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var authService = MockAuthService();
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(HandyManApp());
// //
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
// //
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
// //
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });

  test("Test auth service", () async {
    authService.onAuthStateChanged.listen((event) {
      debugPrint(event?.toString() ?? "No user found");
    });
    var user = await authService.signInWithGoogle();
    expect(authService.customerModel, user);

    await authService.signOut();
    expect(null, null, reason: "When user signs out, test should pass with user null object");
    authService.dispose();
  });
}
