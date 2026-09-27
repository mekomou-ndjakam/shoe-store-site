import 'package:flutter/foundation.dart';

import '../data/catalog_taxonomy.dart';
import '../data/generated_asset_index.dart';
import '../data/product_factory.dart';
import '../models/product.dart';
import '../services/account_service.dart';

export '../services/account_service.dart' show AuthFailure, AuthField, OrderSummary, ShippingAddress;

const String kTout = 'Tout';

class StoreController extends ChangeNotifier {
  StoreController({AccountService? accounts}) : _accounts = accounts ?? AccountService() {
    _restoreSession();
    _loadImportedProducts();
  }

  final AccountService _accounts;

  final List<Product> _products = <Product>[];
  final List<CartLine> _cart = <CartLine>[];
  final Set<int> _favorites = <int>{};

  int activeTab = 0;
  bool isLoadingProducts = true;
  String? loadError;

  Account? _account;

  bool get isAuthenticated => _account != null;
  String? get userName => _account?.name;
  String? get userEmail => _account?.email;
  String? get userPhone => _account?.phone;
  ShippingAddress? get userAddress => _account?.address;
  DateTime? get memberSince => _account?.createdAt;
  List<OrderSummary> get orders => _account?.orders ?? const [];

  /// Throws an [AuthFailure] whose message can be shown as-is to the user.
  Future<void> login({required String email, required String password}) async {
    _setAccount(await _accounts.login(email: email, password: password));
  }

  /// Creates the account and signs the customer in. Throws an [AuthFailure]
  /// when the e-mail address is already used.
  Future<void> signUp({required String name, required String email, required String password}) async {
    _setAccount(await _accounts.signUp(name: name, email: email, password: password));
  }

  Future<void> logout() async {
    await _accounts.logout();
    _setAccount(null);
  }

  Future<void> updateProfile({required String name, required String phone}) {
    return _update({'name': name.trim(), 'phone': phone.trim()});
  }

  Future<void> updateAddress(ShippingAddress address) {
    return _update({'address': address.toJson()});
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _accounts.changePassword(
      email: userEmail!,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> _update(Map<String, dynamic> fields) async {
    _setAccount(await _accounts.update(userEmail!, fields));
  }

  Future<void> _restoreSession() async {
    _setAccount(await _accounts.currentAccount());
  }

  void _setAccount(Account? account) {
    _account = account;
    notifyListeners();
  }

  Future<void> reload() {
    isLoadingProducts = true;
    loadError = null;
    notifyListeners();
    return _loadImportedProducts();
  }

  Future<void> _loadImportedProducts() async {
    try {
      final imported = <Product>[];
      var id = 1;

      kFolderAssets.forEach((folder, paths) {
        for (var index = 0; index < paths.length; index++) {
          imported.add(
            ProductFactory.build(
              id: id++,
              folder: folder,
              indexInFolder: index,
              assetPath: paths[index],
            ),
          );
        }
      });

      _products
        ..clear()
        ..addAll(imported);
    } catch (error) {
      loadError = 'Impossible de charger le catalogue produits.';
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  // ---- Catalogue ----------------------------------------------------

  /// The universe (Homme / Femme) the customer is browsing. Every catalogue
  /// query below only returns products of this universe.
  /// Null shows the whole catalogue (the Homme / Femme switch is hidden for now).
  Gender? gender;

  void setGender(Gender? value) {
    if (value == gender) return;
    gender = value;
    notifyListeners();
  }

  Iterable<Product> get _inGender =>
      gender == null ? _products : _products.where((product) => product.genders.contains(gender));

  List<Product> get products => List.unmodifiable(_inGender);

  List<Product> get featuredProducts =>
      _inGender.where((product) => product.isFeatured).take(10).toList();

  /// A stable, varied sample for the homepage "trending" section: a handful
  /// of products from each category rather than 10 items from one brand.
  List<Product> get trendingProducts {
    final result = <Product>[];
    for (final category in categories) {
      result.addAll(_inGender.where((p) => p.category == category).take(4));
    }
    return result;
  }

  List<String> get categories => CatalogTaxonomy.categories
      .where((category) => _inGender.any((product) => product.category == category))
      .toList();

  List<String> subcategoriesFor(String category) => CatalogTaxonomy.subcategoriesFor(category)
      .where((sub) => _inGender.any((product) => product.category == category && product.subCategory == sub))
      .toList();

  static const _menNavOrder = [
    'Sneakers', 'Streetwear', 'Clubs européens', 'Équipes nationales', 'Running', 'Manteaux & Vestes',
    'Maisons de luxe', 'Football', 'Montres', 'Lunettes', 'Ceintures', 'Sacs de voyage',
  ];
  static const _womenNavOrder = [
    'Sacs à main', 'Maisons de luxe', 'Souliers de luxe', 'Bijoux', 'Sneakers', 'Maisons emblématiques',
    'Streetwear', 'Manteaux & Vestes', 'Lunettes', 'Vêtements techniques', 'Montres', 'Confort & Sandales',
  ];

  /// (category, subcategory) pairs for the top navigation bar, ordered for
  /// the current universe like the Femme / Homme menus of big retailers.
  List<(String, String)> get navSubcategories {
    final all = <(String, String)>[
      for (final category in categories)
        for (final sub in subcategoriesFor(category)) (category, sub),
    ];
    final order = gender == Gender.femme ? _womenNavOrder : _menNavOrder;
    // Listed subcategories first, the others keep their catalogue order.
    int rank((String, String) entry) {
      final index = order.indexOf(entry.$2);
      return index == -1 ? order.length + all.indexOf(entry) : index;
    }
    return [...all]..sort((a, b) => rank(a).compareTo(rank(b)));
  }

  int countForCategory(String category) =>
      _inGender.where((product) => product.category == category).length;

  List<String> brandsFor({required String category, String subCategory = kTout}) {
    final scoped = _inGender.where((product) {
      final matchesCategory = product.category == category;
      final matchesSub = subCategory == kTout || product.subCategory == subCategory;
      return matchesCategory && matchesSub;
    });

    final counts = <String, int>{};
    for (final product in scoped) {
      counts[product.brand] = (counts[product.brand] ?? 0) + 1;
    }
    final brands = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return brands;
  }

  /// Stateless filter+sort used by browsing pages, which own their own
  /// filter selections locally instead of mutating shared controller state.
  List<Product> browse({
    required String category,
    String subCategory = kTout,
    String brand = kTout,
    String query = '',
    ProductSort sort = ProductSort.relevance,
  }) {
    Iterable<Product> result = _inGender.where((product) => product.category == category);

    if (subCategory != kTout) {
      result = result.where((product) => product.subCategory == subCategory);
    }
    if (brand != kTout) {
      result = result.where((product) => product.brand == brand);
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((product) =>
          product.name.toLowerCase().contains(q) || product.brand.toLowerCase().contains(q));
    }

    return _sorted(result.toList(), sort);
  }

  List<Product> globalSearch(String query, {ProductSort sort = ProductSort.relevance}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final result = _inGender.where((product) =>
        product.name.toLowerCase().contains(q) ||
        product.brand.toLowerCase().contains(q) ||
        product.category.toLowerCase().contains(q) ||
        product.subCategory.toLowerCase().contains(q));
    return _sorted(result.toList(), sort);
  }

  List<Product> _sorted(List<Product> list, ProductSort sort) {
    switch (sort) {
      case ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSort.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      case ProductSort.relevance:
        break;
    }
    return list;
  }

  // ---- Favorites ------------------------------------------------------

  List<Product> get favoriteProducts =>
      _products.where((product) => _favorites.contains(product.id)).toList();

  bool isFavorite(Product product) => _favorites.contains(product.id);

  void toggleFavorite(Product product) {
    if (_favorites.contains(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites.add(product.id);
    }
    notifyListeners();
  }

  void removeFavorite(int productId) {
    _favorites.remove(productId);
    notifyListeners();
  }

  // ---- Cart -------------------------------------------------------------

  /// One line per product and size, in the order they were added.
  List<CartLine> get cartLines => List.unmodifiable(_cart);

  int get cartCount => _cart.fold<int>(0, (sum, line) => sum + line.quantity);

  double get cartSubtotal => _cart.fold<double>(0, (sum, line) => sum + line.total);

  double get shippingCost => cartCount == 0 ? 0 : 12.9;

  double get total => cartSubtotal + shippingCost;

  bool get isCartEmpty => cartCount == 0;

  CartLine? _lineFor(Product product, String? size) {
    for (final line in _cart) {
      if (line.product.id == product.id && line.size == size) return line;
    }
    return null;
  }

  /// Adds [quantity] of [product] in [size] (null for one-size items).
  void addToCart(Product product, {String? size, int quantity = 1}) {
    assert(!product.needsSize || size != null, 'A size is required for ${product.name}');
    final line = _lineFor(product, size);
    if (line == null) {
      _cart.add(CartLine(product: product, size: size, quantity: quantity));
    } else {
      line.quantity += quantity;
    }
    notifyListeners();
  }

  void incrementLine(CartLine line) {
    line.quantity++;
    notifyListeners();
  }

  void decrementLine(CartLine line) {
    if (line.quantity <= 1) {
      _cart.remove(line);
    } else {
      line.quantity--;
    }
    notifyListeners();
  }

  void removeLine(CartLine line) {
    _cart.remove(line);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Finalises the order: returns an order reference and empties the cart.
  /// Signed-in customers also get the order saved in their order history.
  String placeOrder() {
    final reference = 'AUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    if (isAuthenticated) {
      final order = OrderSummary(
        reference: reference,
        date: DateTime.now(),
        total: total,
        itemCount: cartCount,
      );
      final history = [order, ...orders].take(20).map((o) => o.toJson()).toList();
      _update({'orders': history}).catchError((_) {});
    }
    clearCart();
    return reference;
  }

  // ---- Reviews ------------------------------------------------------

  void addReview(int productId, int rating, String author, String comment) {
    final product = _products.firstWhere((item) => item.id == productId, orElse: () => _products.first);
    product.reviews.add(
      ProductReview(
        author: author.trim().isEmpty ? 'Client AURORA' : author.trim(),
        rating: rating,
        comment: comment.trim().isEmpty ? 'Très bon article.' : comment.trim(),
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ---- Navigation ------------------------------------------------------

  final List<int> _tabHistory = <int>[];

  /// True when [goBack] can return to a previously visited tab.
  bool get canGoBack => _tabHistory.isNotEmpty;

  void setTab(int index) {
    if (index == activeTab) return;
    _tabHistory
      ..remove(index)
      ..add(activeTab);
    activeTab = index;
    notifyListeners();
  }

  void goBack() {
    if (_tabHistory.isEmpty) return;
    activeTab = _tabHistory.removeLast();
    notifyListeners();
  }
}

class CartLine {
  CartLine({required this.product, required this.size, required this.quantity});

  final Product product;

  /// Chosen size, or null for one-size items.
  final String? size;
  int quantity;

  double get total => product.price * quantity;
}

enum ProductSort { relevance, priceAsc, priceDesc, newest }

extension ProductSortLabel on ProductSort {
  String get label {
    switch (this) {
      case ProductSort.relevance:
        return 'Pertinence';
      case ProductSort.priceAsc:
        return 'Prix croissant';
      case ProductSort.priceDesc:
        return 'Prix décroissant';
      case ProductSort.newest:
        return 'Nouveautés';
    }
  }
}
