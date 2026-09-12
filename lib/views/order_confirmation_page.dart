import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, required this.controller, required this.reference});

  final StoreController controller;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: const BoxDecoration(color: Color(0xFFE3F5EB), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 56),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Merci pour votre commande !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre paiement a été validé. Un e-mail de confirmation vous a été envoyé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9), height: 1.5),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Numéro de commande', style: TextStyle(color: AppColors.textSecondary)),
                      Text(reference, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Continuer mes achats',
                    onPressed: () {
                      controller.setTab(0);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.setTab(4);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Voir mes commandes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
