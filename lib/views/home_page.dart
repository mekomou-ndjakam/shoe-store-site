import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../data/catalog_taxonomy.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/product_card.dart';
import '../widgets/quick_add.dart';
import 'category_page.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final StoreController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _heroController = PageController();
  Timer? _heroTimer;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroController.hasClients) return;
      final slideCount = widget.controller.categories.length;
      if (slideCount == 0) return;
      final nextIndex = (_currentSlide + 1) % slideCount;
      _heroController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  void _openCategory(String category, [String subCategory = kTout]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryPage(
          controller: widget.controller,
          category: category,
          initialSubCategory: subCategory,
        ),
      ),
    );
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product, controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller.isLoadingProducts) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (controller.products.isEmpty) {
      return _EmptyCatalog(onRetry: () => controller.reload());
    }

    final categories = controller.categories;
    final products = controller.products;
    final gender = controller.gender;
    final isMen = gender != Gender.femme;
    // Lead with a piece that is specific to the universe when there is one.
    final heroProduct = products.firstWhere(
      (product) => isMen ? product.category == 'Chaussures' : product.genders.length == 1,
      orElse: () => products.first,
    );
    final latest = products.reversed.take(12).toList();
    final shoes = products.where((product) => product.category == 'Chaussures').take(12).toList();

    // One eye-catching piece per category for the collage, universe-specific
    // pieces first so Femme and Homme don't look alike.
    const menOrder = ['Chaussures', 'Mode & Streetwear', 'Maillots & Sport', 'Accessoires', 'Sacs & Maroquinerie'];
    const womenOrder = ['Sacs & Maroquinerie', 'Mode & Streetwear', 'Chaussures', 'Accessoires', 'Maillots & Sport'];
    final collage = <Product>[];
    for (final category in isMen ? menOrder : womenOrder) {
      final inCategory = products.where((p) => p.category == category).toList();
      if (inCategory.isEmpty) continue;
      int score(Product p) => (p.genders.length == 1 ? 2 : 0) + (p.isFeatured ? 1 : 0);
      inCategory.sort((a, b) => score(b).compareTo(score(a)));
      collage.add(inCategory.first);
    }

    return ContentWidth(
      maxWidth: 1200,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _SubcategoryNav(
            entries: controller.navSubcategories,
            onAll: () => controller.setTab(1),
            onSelected: (entry) => _openCategory(entry.$1, entry.$2),
          ),
          const SizedBox(height: 14),
          _HeroCollage(
            products: collage,
            label: gender == null ? 'AURORA' : 'AURORA ${gender.label.toUpperCase()}',
            onDiscover: () => controller.setTab(1),
            onTileTap: (product) => _openCategory(product.category, product.subCategory),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Shopper par univers', onSeeAll: () => controller.setTab(1)),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryPill(
                  category: category,
                  onTap: () => _openCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 34),
          _ProductRail(
            title: gender == null ? 'Nouveautés' : (isMen ? 'Nouveautés pour lui' : 'Nouveautés pour elle'),
            subtitle: 'Les pièces qui viennent d’arriver',
            products: latest,
            controller: controller,
            onSeeAll: () => controller.setTab(1),
            onProductTap: _openProduct,
          ),
          const SizedBox(height: 34),
          _EditorialBanner(product: heroProduct, onTap: () => _openCategory(heroProduct.category)),
          const SizedBox(height: 34),
          if (shoes.isNotEmpty)
            _ProductRail(
              title: 'Les sneakers du moment',
              subtitle: 'Des silhouettes faites pour tous les jours',
              products: shoes,
              controller: controller,
              onSeeAll: () => _openCategory('Chaussures'),
              onProductTap: _openProduct,
            ),
          const SizedBox(height: 34),
          const _SectionTitle(title: 'Les services AURORA'),
          const SizedBox(height: 14),
          const _TrustStrip(),
        ],
      ),
    );
  }
}

/// Editorial banner: the headline on a dark panel next to a mosaic of five
/// Horizontal text menu of subcategories ("Toute la collection", "Sneakers"…)
/// whose content and order follow the selected universe.
class _SubcategoryNav extends StatelessWidget {
  const _SubcategoryNav({required this.entries, required this.onAll, required this.onSelected});

  final List<(String, String)> entries;
  final VoidCallback onAll;
  final ValueChanged<(String, String)> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget item(String label, VoidCallback onTap, {bool strong = false}) => InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                color: strong ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        );

    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          item('Toute la collection', onAll, strong: true),
          for (final entry in entries) item(entry.$2, () => onSelected(entry)),
        ],
      ),
    );
  }
}

/// products taken from different categories of the current universe.
class _HeroCollage extends StatelessWidget {
  const _HeroCollage({
    required this.products,
    required this.label,
    required this.onDiscover,
    required this.onTileTap,
  });

  final List<Product> products;
  final String label;
  final VoidCallback onDiscover;
  final ValueChanged<Product> onTileTap;

  Widget _tile(int index) {
    if (index >= products.length) return const ColoredBox(color: Color(0xFFEDEBEA));
    final product = products[index];
    return _CollageTile(product: product, onTap: () => onTileTap(product));
  }

  @override
  Widget build(BuildContext context) {
    const gap = 3.0;
    final headline = Container(
      color: AppColors.navy,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 10),
          const Text(
            'Le style commence ici.',
            style: TextStyle(color: Colors.white, fontSize: 32, height: 1.1, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sneakers, maillots, mode, maroquinerie et accessoires : une sélection pensée pour vous.',
            style: TextStyle(color: Color(0xCCFFFFFF), height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onDiscover,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            child: const Text('DÉCOUVRIR LA SÉLECTION', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final mosaic = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _tile(0)),
                  const SizedBox(width: gap),
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      Expanded(child: _tile(1)),
                      const SizedBox(height: gap),
                      Expanded(child: _tile(2)),
                    ]),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      Expanded(child: _tile(3)),
                      const SizedBox(height: gap),
                      Expanded(child: _tile(4)),
                    ]),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _tile(0)),
                  const SizedBox(width: gap),
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      Expanded(child: _tile(1)),
                      const SizedBox(height: gap),
                      Expanded(child: _tile(2)),
                    ]),
                  ),
                ],
              );

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: wide
              ? SizedBox(
                  height: 400,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 340, child: headline),
                      const SizedBox(width: gap),
                      Expanded(child: mosaic),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 280, child: mosaic),
                    headline,
                  ],
                ),
        );
      },
    );
  }
}

class _CollageTile extends StatefulWidget {
  const _CollageTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  State<_CollageTile> createState() => _CollageTileState();
}

class _CollageTileState extends State<_CollageTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFEDEBEA),
              child: AnimatedScale(
                scale: _hovered ? 1.06 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: AppImage(product.gallery.first, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.white.withValues(alpha: 0.92),
                child: Text(
                  product.subCategory.toUpperCase(),
                  style: const TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.onTap});

  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(category, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({
    required this.title,
    required this.subtitle,
    required this.products,
    required this.controller,
    required this.onSeeAll,
    required this.onProductTap,
  });

  final String title;
  final String subtitle;
  final List<Product> products;
  final StoreController controller;
  final VoidCallback onSeeAll;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, subtitle: subtitle, onSeeAll: onSeeAll),
        const SizedBox(height: 14),
        SizedBox(
          height: 332,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 190,
                child: ProductCard(
                  product: product,
                  isFavorite: controller.isFavorite(product),
                  onAddToCart: (p) => quickAddToCart(context, controller, p),
                  onToggleFavorite: controller.toggleFavorite,
                  onTap: () => onProductTap(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EditorialBanner extends StatelessWidget {
  const _EditorialBanner({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        color: const Color(0xFFE8E3DA),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LE LOOK DE LA SEMAINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Des essentiels simples. Une allure qui reste.', style: TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  TextButton(onPressed: onTap, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: const Text('Voir la sélection  →')),
                ],
              ),
            ),
            SizedBox(width: 150, height: 150, child: AppImage(product.gallery.first, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Le catalogue n’a pas pu être chargé.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.category, required this.sampleProduct, required this.onTap});

  final String category;
  final Product sampleProduct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CatalogTaxonomy.colorFor(category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: color.withValues(alpha: 0.10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppImage(
                sampleProduct.gallery.first,
                fit: BoxFit.cover,
                backgroundColor: color.withValues(alpha: 0.10),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.heroOverlay),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Découvrir',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.count, required this.onTap});

  final String category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CatalogTaxonomy.colorFor(category);
    final icon = CatalogTaxonomy.iconFor(category);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Text(
                      '$count articles',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle, this.onSeeAll});

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_outlined, 'Livraison 48h', 'Partout en France'),
      (Icons.replay_rounded, 'Retours faciles', 'Sous 14 jours'),
      (Icons.lock_outline_rounded, 'Paiement sécurisé', 'Carte, PayPal, Apple Pay'),
    ];

    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(item.$1, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text(item.$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
