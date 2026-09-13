import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../data/catalog_taxonomy.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/product_card.dart';
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

  void _openCategory(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryPage(controller: widget.controller, category: category),
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
    final heroProduct = products.first;
    final latest = products.reversed.take(12).toList();
    final shoes = products.where((product) => product.category == 'Chaussures').take(12).toList();

    return ContentWidth(
      maxWidth: 1200,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: [
          _HomeHero(product: heroProduct, onTap: () => _openCategory(heroProduct.category)),
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
                  count: controller.countForCategory(category),
                  onTap: () => _openCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 34),
          _ProductRail(
            title: 'Nouveautés pour lui',
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

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 330,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(4)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(product.gallery.first, fit: BoxFit.cover),
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroOverlay)),
            Positioned(
              left: 26,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AURORA HOMME', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Le style commence ici.', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  FilledButton.tonal(onPressed: onTap, child: const Text('Découvrir la sélection')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.count, required this.onTap});

  final String category;
  final int count;
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
      child: Text('$category  $count', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                  onAddToCart: controller.addToCart,
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
