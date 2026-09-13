import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/catalog_taxonomy.dart';
import '../data/generated_asset_index.dart';
import '../data/product_factory.dart';
import '../models/product.dart';

const String kTout = 'Tout';

class StoreController extends ChangeNotifier {
  StoreController({this.authEnabled = false}) {
    if (authEnabled) _restoreSession();
    _loadImportedProducts();
    if (authEnabled) {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        _applySession(data.session);
        notifyListeners();
      });
    }
  }

  final bool authEnabled;

  final List<Product> _products = <Product>[];
  final Map<int, int> _cart = {};
  final Set<int> _favorites = <int>{};

  int activeTab = 0;
  bool isLoadingProducts = true;
  String? loadError;

  bool isAuthenticated = false;
  String? userName;
  String? userEmail;

  Future<void> login({required String email, required String password}) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  void _restoreSession() {
    _applySession(Supabase.instance.client.auth.currentSession);
  }

  void _applySession(Session? session) {
    final user = session?.user;
    isAuthenticated = user != null;
    userEmail = user?.email;
    userName = user?.userMetadata?['full_name'] as String? ?? user?.email?.split('@').first;
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

  List<Product> get products => List.unmodifiable(_products);

  List<Product> get featuredProducts =>
      _products.where((product) => product.isFeatured).take(10).toList();

  /// A stable, varied sample for the homepage "trending" section: a handful
  /// of products from each category rather than 10 items from one brand.
  List<Product> get trendingProducts {
    final result = <Product>[];
    for (final category in CatalogTaxonomy.categories) {
      result.addAll(_products.where((p) => p.category == category).take(4));
    }
    return result;
  }

  List<String> get categories => CatalogTaxonomy.categories;

  List<String> subcategoriesFor(String category) => CatalogTaxonomy.subcategoriesFor(category);

  int countForCategory(String category) =>
      _products.where((product) => product.category == category).length;

  List<String> brandsFor({required String category, String subCategory = kTout}) {
    final scoped = _products.where((product) {
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
    Iterable<Product> result = _products.where((product) => product.category == category);

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
    final result = _products.where((product) =>
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

  List<Product> get cartItems =>
      _products.where((product) => (_cart[product.id] ?? 0) > 0).toList();

  int get cartCount => _cart.values.fold<int>(0, (sum, quantity) => sum + quantity);

  double get cartSubtotal {
    return cartItems.fold<double>(0, (sum, product) {
      final quantity = _cart[product.id] ?? 0;
      return sum + (product.price * quantity);
    });
  }

  double get shippingCost => cartCount == 0 ? 0 : 12.9;

  double get total => cartSubtotal + shippingCost;

  bool get isCartEmpty => cartCount == 0;

  int quantityFor(Product product) => _cart[product.id] ?? 0;

  void addToCart(Product product) {
    _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeOneFromCart(int productId) {
    final quantity = _cart[productId] ?? 0;
    if (quantity <= 1) {
      _cart.remove(productId);
    } else {
      _cart[productId] = quantity - 1;
    }
    notifyListeners();
  }

  void removeProductLine(int productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Finalises the order: returns an order reference and empties the cart.
  String placeOrder() {
    final reference = 'AUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
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

  void setTab(int index) {
    activeTab = index;
    notifyListeners();
  }
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
