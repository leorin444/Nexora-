import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_mobile/main.dart';
import 'package:provider/provider.dart';
import 'package:nexora_mobile/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const NexoraApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
