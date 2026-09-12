import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../data/catalog_taxonomy.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

const int _pageSize = 20;

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.controller,
    required this.category,
    this.initialSubCategory = kTout,
  });

  final StoreController controller;
  final String category;
  final String initialSubCategory;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String _subCategory = widget.initialSubCategory;
  String _brand = kTout;
  ProductSort _sort = ProductSort.relevance;
  int _displayCount = _pageSize;

  void _resetPaging() => setState(() => _displayCount = _pageSize);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final subCategories = controller.subcategoriesFor(widget.category);
    final brands = controller.brandsFor(category: widget.category, subCategory: _subCategory);
    final results = controller.browse(
      category: widget.category,
      subCategory: _subCategory,
      brand: _brand,
      sort: _sort,
    );
    final visible = results.take(_displayCount).toList();
    final color = CatalogTaxonomy.colorFor(widget.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.category)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ContentWidth(
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subCategories.isNotEmpty) ...[
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: subCategories.length + 1,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final label = index == 0 ? kTout : subCategories[index - 1];
                              final selected = _subCategory == label;
                              return _FilterChip(
                                label: label,
                                selected: selected,
                                color: color,
                                onTap: () {
                                  setState(() {
                                    _subCategory = label;
                                    _brand = kTout;
                                  });
                                  _resetPaging();
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (brands.length > 1) ...[
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: brands.length + 1,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final label = index == 0 ? kTout : brands[index - 1];
                              final selected = _brand == label;
                              return _FilterChip(
                                label: label,
                                selected: selected,
                                color: AppColors.textPrimary,
                                compact: true,
                                onTap: () {
                                  setState(() => _brand = label);
                                  _resetPaging();
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${results.length} article${results.length > 1 ? 's' : ''}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          _SortMenu(
                            value: _sort,
                            onChanged: (value) {
                              setState(() => _sort = value);
                              _resetPaging();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
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
                          onAddToCart: (p) {
                            controller.addToCart(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 900),
                                content: Text('${p.name.split(' · ').first} ajouté au panier'),
                              ),
                            );
                          },
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
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: visible.length < results.length
                          ? OutlinedButton(
                              onPressed: () => setState(() => _displayCount += _pageSize),
                              child: const Text('Charger plus'),
                            )
                          : const Text(
                              'Vous avez tout vu ✓',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                    ),
                  ),
                ),
              ],
            ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 6 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onChanged});

  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductSort>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => ProductSort.values
          .map((sort) => PopupMenuItem(value: sort, child: Text(sort.label)))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Aucun article ne correspond à ces filtres.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
