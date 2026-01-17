// Basic Flutter widget tests for vCard Studio.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vcard_studio/main.dart';

void main() {
  testWidgets('VCard Studio smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VCardStudioApp()));

    // Verify that the app starts correctly
    await tester.pumpAndSettle();

    // Check for the app title or main UI element
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
