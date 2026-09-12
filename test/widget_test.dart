// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:aurora_store/app.dart';
import 'package:aurora_store/controllers/store_controller.dart';
import 'package:aurora_store/views/category_page.dart';
import 'package:aurora_store/views/checkout_page.dart';
import 'package:aurora_store/views/catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aurora storefront loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AuroraApp());

    expect(find.textContaining('AURORA'), findsWidgets);
  });

  testWidgets('Checkout shows realistic payment fields for the selected method', (WidgetTester tester) async {
    final controller = StoreController();
    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutPage(controller: controller),
      ),
    );

    expect(find.text('Numéro de carte'), findsOneWidget);

    await tester.ensureVisible(find.text('PayPal'));
    await tester.tap(find.text('PayPal'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail PayPal'), findsOneWidget);

    await tester.ensureVisible(find.text('Apple Pay'));
    await tester.tap(find.text('Apple Pay'));
    await tester.pumpAndSettle();

    expect(find.text('Compte Apple Pay'), findsOneWidget);
  });

  testWidgets('Catalog opens a category browsing page', (WidgetTester tester) async {
    final controller = StoreController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogPage(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chaussures'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryPage), findsOneWidget);
  });
}
