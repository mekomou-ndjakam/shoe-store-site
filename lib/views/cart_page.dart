import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.cartItems;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ContentWidth(
              child: items.isEmpty ? _EmptyCart(controller: controller) : _CartContent(controller: controller, items: items),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(color: Color(0xFFFFE7DB), shape: BoxShape.circle),
              child: const Center(
                child: Icon(Icons.shopping_bag_outlined, size: 52, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre panier est vide',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Parcourez nos univers et ajoutez vos coups de cœur.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            GradientButton(label: 'Découvrir la boutique', onPressed: () => controller.setTab(1)),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.controller, required this.items});

  final StoreController controller;
  final List items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              const Text(
                'Mon panier',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Text('(${controller.cartCount})', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              final quantity = controller.quantityFor(product);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColoredBox(
                        color: const Color(0xFFF3EFE8),
                        child: AppImage(
                          product.gallery.isNotEmpty ? product.gallery.first : '',
                          width: 74,
                          height: 74,
                          fit: BoxFit.contain,
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
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(product.brand, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                            '${product.price.toStringAsFixed(0)} €',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () => controller.removeOneFromCart(product.id),
                            ),
                            SizedBox(
                              width: 26,
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => controller.addToCart(product),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => controller.removeProductLine(product.id),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'Retirer',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Sous-total', value: controller.cartSubtotal),
              const SizedBox(height: 6),
              _SummaryRow(label: 'Livraison', value: controller.shippingCost),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppColors.border)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text(
                    '${controller.total.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Passer la commande',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CheckoutPage(controller: controller)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text('${value.toStringAsFixed(2)} €', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
