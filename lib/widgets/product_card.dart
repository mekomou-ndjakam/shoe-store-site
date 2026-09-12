import 'package:flutter/material.dart';

import '../models/product.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final ValueChanged<Product> onAddToCart;
  final ValueChanged<Product> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final image = product.gallery.isNotEmpty ? product.gallery.first : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBE5DB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: const Color(0xFFF3EFE8),
                    child: AppImage(image, fit: BoxFit.contain),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: () => onToggleFavorite(product),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: product.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name.split(' · ').first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15130F),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.price.toStringAsFixed(0)} €',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15130F),
                          ),
                        ),
                      ),
                      _AddButton(onPressed: () => onAddToCart(product)),
                    ],
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

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? const Color(0xFFE1443B) : const Color(0xFF15130F),
          size: 18,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF15130F),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
