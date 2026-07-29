// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glow_in_the_damp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Glow in the Damp app loads onboarding', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'gid_user_first_time': true});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(child: MyApp(preferences: preferences)),
    );
    await tester.pump();

    expect(find.text('GLOW\nIN THE\nDAMP.'), findsOneWidget);
    expect(find.text('Open Dissipation Archive'), findsOneWidget);
  });
}
