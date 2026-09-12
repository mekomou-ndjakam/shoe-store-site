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
    final trending = controller.trendingProducts;
    final heroSlides = <(String category, Product sample)>[];
    for (final category in categories) {
      final inCategory = controller.products.where((p) => p.category == category).toList();
      if (inCategory.isEmpty) continue;
      // The first photo of a folder is often a cover/logo graphic rather than
      // the item itself, so pick a bit further into the list to represent
      // the category with an actual product shot.
      final representativeIndex = (inCategory.length / 3).floor().clamp(0, inCategory.length - 1);
      heroSlides.add((category, inCategory[representativeIndex]));
    }

    return ContentWidth(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
        if (heroSlides.isNotEmpty) ...[
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _heroController,
              itemCount: heroSlides.length,
              onPageChanged: (index) => setState(() => _currentSlide = index),
              itemBuilder: (context, index) {
                final slide = heroSlides[index];
                return _HeroSlide(
                  category: slide.$1,
                  sampleProduct: slide.$2,
                  onTap: () => _openCategory(slide.$1),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              heroSlides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentSlide == index ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentSlide == index ? AppColors.textPrimary : const Color(0xFFD8D2C6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Univers'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 68,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryTile(
              category: category,
              count: controller.countForCategory(category),
              onTap: () => _openCategory(category),
            );
          },
        ),
        const SizedBox(height: 30),
        _SectionTitle(
          title: 'Tendances du moment',
          onSeeAll: () => controller.setTab(1),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trending.length > 8 ? 8 : trending.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final product = trending[index];
            return ProductCard(
              product: product,
              isFavorite: controller.isFavorite(product),
              onAddToCart: controller.addToCart,
              onToggleFavorite: controller.toggleFavorite,
              onTap: () => _openProduct(product),
            );
          },
        ),
        const SizedBox(height: 30),
        const _SectionTitle(title: 'Pourquoi AURORA'),
        const SizedBox(height: 14),
        const _TrustStrip(),
        ],
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
  const _SectionTitle({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
