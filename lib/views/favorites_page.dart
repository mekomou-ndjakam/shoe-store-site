import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final favorites = controller.favoriteProducts;

        return SafeArea(
          child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes favoris',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: favorites.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textSecondary),
                              const SizedBox(height: 12),
                              const Text(
                                'Aucun favori pour le moment.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 18),
                              GradientButton(
                                label: 'Explorer la boutique',
                                onPressed: () => controller.setTab(1),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: favorites.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = favorites[index];
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(product: product, controller: controller),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ColoredBox(
                                        color: const Color(0xFFF3EFE8),
                                        child: AppImage(
                                          product.gallery.isNotEmpty ? product.gallery.first : '',
                                          width: 78,
                                          height: 78,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name.split(' · ').first,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.price.toStringAsFixed(0)} €',
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      controller.addToCart(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(duration: Duration(milliseconds: 900), content: Text('Ajouté au panier')),
                                      );
                                    },
                                    icon: const Icon(Icons.shopping_bag_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () => controller.removeFavorite(product.id),
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
