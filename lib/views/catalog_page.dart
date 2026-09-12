import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../data/catalog_taxonomy.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/product_card.dart';
import 'category_page.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});

  final StoreController controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _displayCount = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final searching = _query.trim().isNotEmpty;
    final results = searching ? controller.globalSearch(_query) : const <Product>[];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trouver un article',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value;
                    _displayCount = 20;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un article, une marque...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searching
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: searching
                      ? _SearchResults(
                          controller: controller,
                          results: results,
                          displayCount: _displayCount,
                          onLoadMore: () => setState(() => _displayCount += 20),
                        )
                      : _CategoryDirectory(controller: controller),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

class _CategoryDirectory extends StatelessWidget {
  const _CategoryDirectory({required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories;
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = CatalogTaxonomy.colorFor(category);
        final icon = CatalogTaxonomy.iconFor(category);
        final subCount = controller.subcategoriesFor(category).length;
        final productCount = controller.countForCategory(category);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryPage(controller: controller, category: category),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$subCount sous-catégories · $productCount articles',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.controller,
    required this.results,
    required this.displayCount,
    required this.onLoadMore,
  });

  final StoreController controller;
  final List<Product> results;
  final int displayCount;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text('Aucun résultat pour cette recherche.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final visible = results.take(displayCount).toList();

    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.66,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = visible[index];
              return ProductCard(
                product: product,
                isFavorite: controller.isFavorite(product),
                onAddToCart: controller.addToCart,
                onToggleFavorite: controller.toggleFavorite,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product, controller: controller),
                    ),
                  );
                },
              );
            },
            childCount: visible.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: visible.length < results.length
                  ? OutlinedButton(onPressed: onLoadMore, child: const Text('Charger plus'))
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
