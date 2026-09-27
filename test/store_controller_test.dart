import 'package:aurora_store/controllers/store_controller.dart';
import 'package:aurora_store/models/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('le panier sépare les tailles d’un même article', () async {
    final controller = StoreController();
    await Future<void>.delayed(Duration.zero);
    final shoe = controller.products.firstWhere((p) => p.category == 'Chaussures');
    expect(shoe.needsSize, isTrue);

    controller.addToCart(shoe, size: '42', quantity: 2);
    controller.addToCart(shoe, size: '43');
    controller.addToCart(shoe, size: '42');

    expect(controller.cartLines.length, 2);
    expect(controller.cartLines.first.quantity, 3);
    expect(controller.cartCount, 4);
    expect(controller.cartSubtotal, shoe.price * 4);

    controller.decrementLine(controller.cartLines.last);
    expect(controller.cartLines.length, 1);
  });

  test('les articles sans taille n’en demandent pas', () {
    final controller = StoreController();
    final watch = controller.products.firstWhere((p) => p.subCategory == 'Montres');
    expect(watch.needsSize, isFalse);
  });

  test('l’univers Femme montre ses articles, l’univers Homme les masque', () {
    final controller = StoreController();
    bool hasHandbag() => controller.products.any((p) => p.subCategory == 'Sacs à main');

    expect(controller.gender, isNull);
    expect(hasHandbag(), isTrue, reason: "sans univers choisi, tout le catalogue est visible");

    controller.setGender(Gender.homme);
    expect(hasHandbag(), isFalse);
    expect(controller.subcategoriesFor('Sacs & Maroquinerie'), isNot(contains('Sacs à main')));

    controller.setGender(Gender.femme);
    expect(hasHandbag(), isTrue);
    expect(controller.products.every((p) => p.genders.contains(Gender.femme)), isTrue);
  });

  test('la flèche retour ramène à l’onglet précédent', () {
    final controller = StoreController();
    expect(controller.canGoBack, isFalse);
    controller.setTab(1);
    controller.setTab(2);
    controller.goBack();
    expect(controller.activeTab, 1);
    controller.goBack();
    expect(controller.activeTab, 0);
    expect(controller.canGoBack, isFalse);
  });

  test('le menu des sous-catégories change avec Homme / Femme', () {
    final controller = StoreController();
    expect(controller.navSubcategories.first.$2, 'Sneakers');
    expect(controller.navSubcategories.map((e) => e.$2), contains('Sacs à main'));

    controller.setGender(Gender.homme);
    expect(controller.navSubcategories.map((e) => e.$2), isNot(contains('Sacs à main')));

    controller.setGender(Gender.femme);
    expect(controller.navSubcategories.first, ('Sacs & Maroquinerie', 'Sacs à main'));
  });
}
