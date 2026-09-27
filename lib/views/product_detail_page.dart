import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/size_selector.dart';

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
  String? _size;
  int _quantity = 1;
  bool _showSizeError = false;

  static const _maxQuantity = 10;

  @override
  void dispose() {
    _reviewNameController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  String _price(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

  Widget _buildStars({required int value, double size = 18, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < value;
        return Icon(
          active ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: active ? AppColors.textPrimary : (color ?? AppColors.border),
        );
      }),
    );
  }

  void _openCart() {
    widget.controller.setTab(2);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _addToCart() {
    final product = widget.product;
    if (product.needsSize && _size == null) {
      setState(() => _showSizeError = true);
      return;
    }
    widget.controller.addToCart(product, size: _size, quantity: _quantity);
    final sizeText = _size == null ? '' : ' · ${product.sizeKind.label.split(' ').first} $_size';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1600),
          content: Text('${product.name.split(' · ').first}$sizeText ×$_quantity ajouté au panier'),
          action: SnackBarAction(label: 'Voir le panier', onPressed: _openCart),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final product = widget.product;
        final image = product.gallery.isNotEmpty ? product.gallery.first : '';
        final cartCount = widget.controller.cartCount;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: Text(product.brand),
            actions: [
              IconButton(
                tooltip: 'Panier',
                onPressed: _openCart,
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: ContentWidth(
              maxWidth: 1200,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final picture = AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ColoredBox(
                      color: const Color(0xFFEDEBEA),
                      child: AppImage(image, fit: BoxFit.contain),
                    ),
                  );
                  final buyBox = _buildBuyBox(product);
                  final details = _buildDetails(product);

                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [picture, const SizedBox(height: 20), buyBox, const SizedBox(height: 32), details],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: picture),
                          const SizedBox(width: 48),
                          Expanded(flex: 4, child: buyBox),
                        ],
                      ),
                      const SizedBox(height: 40),
                      details,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuyBox(Product product) {
    final isFavorite = widget.controller.isFavorite(product);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.brand.toUpperCase(),
          style: const TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          product.name.split(' · ').first,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          '${product.subCategory} · ${product.genders.length == 2 ? 'Mixte' : product.genders.first.label}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 22),
        if (product.needsSize) ...[
          SizeSelector(
            product: product,
            selected: _size,
            showError: _showSizeError,
            onSelected: (size) => setState(() {
              _size = size;
              _showSizeError = false;
            }),
          ),
          Align(alignment: Alignment.centerRight, child: SizeGuideButton(kind: product.sizeKind)),
        ] else
          const Text('Taille : unique', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _price(product.price),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ),
            if (product.reviews.isNotEmpty)
              Row(
                children: [
                  _buildStars(value: product.averageRating.round(), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${product.averageRating.toStringAsFixed(1).replaceAll('.', ',')} (${product.reviewCount})',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _QuantityStepper(
              value: _quantity,
              max: _maxQuantity,
              onChanged: (value) => setState(() => _quantity = value),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _addToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: const StadiumBorder(),
                ),
                child: const Text('AJOUTER AU PANIER', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => widget.controller.toggleFavorite(product),
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: isFavorite ? AppColors.danger : AppColors.textPrimary,
            ),
            label: Text(
              isFavorite ? 'DANS VOTRE LISTE DE SOUHAITS' : 'AJOUTER À LA LISTE DE SOUHAITS',
              style: const TextStyle(fontSize: 13, letterSpacing: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Livraison à domicile : ${_price(12.9)} par commande.',
          style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDetails(Product product) {
    final reviews = product.reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Text(product.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6)),
        const SizedBox(height: 32),
        const Divider(color: AppColors.border),
        const SizedBox(height: 20),
        const Text('Avis clients', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
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
              decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(review.author, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Laisser un avis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  final ratingValue = index + 1;
                  return IconButton(
                    tooltip: '$ratingValue étoile${ratingValue > 1 ? 's' : ''}',
                    onPressed: () => setState(() => _selectedRating = ratingValue),
                    icon: Icon(
                      _selectedRating >= ratingValue ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF5A623),
                      size: 26,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
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
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.max, required this.onChanged});

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const ShapeDecoration(color: Color(0xFFF4F0EF), shape: StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Diminuer la quantité',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 32,
            child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
          ),
          IconButton(
            tooltip: 'Augmenter la quantité',
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
