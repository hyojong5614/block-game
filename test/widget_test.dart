import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_game/main.dart';

void main() {
  testWidgets('start menu renders and opens classic mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BlockGameApp());

    expect(find.text('Block Game'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);

    await tester.tap(find.text('Classic'));
    await tester.pumpAndSettle();

    expect(find.text('No Space Left'), findsNothing);
    expect(find.text('Block Game'), findsNothing);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
