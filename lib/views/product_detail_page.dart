import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.controller,
  });

  final Product product;
  final StoreController controller;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _reviewNameController = TextEditingController();
  final TextEditingController _reviewCommentController = TextEditingController();
  int _selectedRating = 5;

  @override
  void dispose() {
    _reviewNameController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  Widget _buildStars({required int value, double size = 18, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < value;
        return Icon(
          active ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: active ? const Color(0xFFF5A623) : (color ?? AppColors.border),
        );
      }),
    );
  }

  void _addToCart() {
    widget.controller.addToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: Text('${widget.product.name.split(' · ').first} ajouté au panier'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _buyNow() {
    widget.controller.addToCart(widget.product);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CartPage(controller: widget.controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final product = widget.product;
        final image = product.gallery.isNotEmpty ? product.gallery.first : '';
        final isFavorite = widget.controller.isFavorite(product);
        final reviews = product.reviews;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                expandedHeight: 380,
                actions: [
                  IconButton(
                    onPressed: () => widget.controller.toggleFavorite(product),
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.danger : AppColors.textPrimary,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ColoredBox(
                    color: const Color(0xFFF3EFE8),
                    child: AppImage(image, fit: BoxFit.contain),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: product.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.brand.toUpperCase(),
                          style: TextStyle(
                            color: product.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name.split(' · ').first,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.category} · ${product.subCategory}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${product.price.toStringAsFixed(0)} €',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      const SizedBox(height: 18),
                      if (reviews.isNotEmpty)
                        Row(
                          children: [
                            _buildStars(value: product.averageRating.round()),
                            const SizedBox(width: 10),
                            Text(
                              '${product.averageRating.toStringAsFixed(1)} (${product.reviewCount} avis)',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      Text(
                        product.description,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      const Text(
                        'Avis clients',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      if (reviews.isEmpty)
                        const Text(
                          'Aucun avis pour le moment. Soyez le premier à donner votre avis.',
                          style: TextStyle(color: AppColors.textSecondary),
                        )
                      else
                        ...reviews.map((review) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        review.author,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    _buildStars(value: review.rating, size: 15),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(review.comment, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Laisser un avis',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(5, (index) {
                                final ratingValue = index + 1;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedRating = ratingValue),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      _selectedRating >= ratingValue ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: const Color(0xFFF5A623),
                                      size: 26,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _reviewNameController,
                              decoration: const InputDecoration(labelText: 'Nom ou pseudo'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _reviewCommentController,
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Votre avis'),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_reviewCommentController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Ajoutez un commentaire avant de valider.')),
                                    );
                                    return;
                                  }
                                  widget.controller.addReview(
                                    product.id,
                                    _selectedRating,
                                    _reviewNameController.text,
                                    _reviewCommentController.text,
                                  );
                                  _reviewNameController.clear();
                                  _reviewCommentController.clear();
                                  setState(() => _selectedRating = 5);
                                },
                                child: const Text('Publier l’avis'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('Ajouter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(label: 'Acheter maintenant', onPressed: _buyNow),
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
