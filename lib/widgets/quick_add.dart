import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'size_selector.dart';

/// "Add to cart" from a product card: one-size items go straight to the cart,
/// the others first ask for a size in a bottom sheet.
Future<void> quickAddToCart(BuildContext context, StoreController controller, Product product) async {
  final messenger = ScaffoldMessenger.of(context);
  String? size;
  if (product.needsSize) {
    size = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _SizeSheet(product: product),
    );
    if (size == null) return;
  }
  controller.addToCart(product, size: size);
  final name = product.name.split(' · ').first;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1400),
        content: Text(size == null ? '$name ajouté au panier' : '$name (${product.sizeKind.label.split(' ').first} $size) ajouté au panier'),
        action: SnackBarAction(label: 'Voir', onPressed: () => controller.setTab(2)),
      ),
    );
}

class _SizeSheet extends StatefulWidget {
  const _SizeSheet({required this.product});

  final Product product;

  @override
  State<_SizeSheet> createState() => _SizeSheetState();
}

class _SizeSheetState extends State<_SizeSheet> {
  String? _size;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name.split(' · ').first,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text('${product.price.toStringAsFixed(2).replaceAll('.', ',')} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            SizeSelector(
              product: product,
              selected: _size,
              showError: _showError,
              onSelected: (size) => setState(() => _size = size),
            ),
            Align(alignment: Alignment.centerRight, child: SizeGuideButton(kind: product.sizeKind)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_size == null) {
                    setState(() => _showError = true);
                    return;
                  }
                  Navigator.of(context).pop(_size);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const StadiumBorder(),
                ),
                child: const Text('AJOUTER AU PANIER', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
