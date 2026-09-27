import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import 'auth_page.dart';
import 'checkout_page.dart';

/// Entry point for "Passer la commande": signed-in customers go straight to
/// checkout, others choose between signing in, signing up or paying as guest.
Future<void> startCheckout(BuildContext context, StoreController controller) async {
  final navigator = Navigator.of(context);
  void openCheckout() => navigator.push(
        MaterialPageRoute(builder: (_) => CheckoutPage(controller: controller)),
      );

  if (controller.isAuthenticated) {
    openCheckout();
    return;
  }

  final choice = await showDialog<_CheckoutChoice>(
    context: context,
    builder: (_) => const _CheckoutPromptDialog(),
  );
  if (choice == null) return;

  if (choice == _CheckoutChoice.guest) {
    openCheckout();
    return;
  }

  final signedIn = await navigator.push<bool>(
    MaterialPageRoute(
      builder: (_) => AuthPage(
        controller: controller,
        startInSignUp: choice == _CheckoutChoice.signUp,
      ),
    ),
  );
  if (signedIn == true) openCheckout();
}

enum _CheckoutChoice { login, signUp, guest }

class _CheckoutPromptDialog extends StatelessWidget {
  const _CheckoutPromptDialog();

  @override
  Widget build(BuildContext context) {
    const benefits = [
      'Un bon de réduction de bienvenue',
      'Des offres exclusives réservées aux membres',
      'Le suivi de vos commandes depuis votre compte',
      'Une expérience d’achat plus rapide et plus fluide',
    ];
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
    const buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 18);

    Widget outlined(String label, _CheckoutChoice choice) => OutlinedButton(
          onPressed: () => Navigator.of(context).pop(choice),
          style: OutlinedButton.styleFrom(
            shape: pill,
            padding: buttonPadding,
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.textPrimary),
          ),
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        );

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Passer au paiement',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Créez un compte et bénéficiez de nombreux avantages :',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...benefits.map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_rounded, size: 20, color: AppColors.textPrimary),
                            const SizedBox(width: 12),
                            Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_CheckoutChoice.login),
                      style: FilledButton.styleFrom(
                        shape: pill,
                        padding: buttonPadding,
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('SE CONNECTER ET COMMANDER', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final signUp = outlined('CRÉER UN COMPTE ET COMMANDER', _CheckoutChoice.signUp);
                        final guest = outlined('PAYER EN TANT QU’INVITÉ', _CheckoutChoice.guest);
                        if (constraints.maxWidth < 420) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [signUp, const SizedBox(height: 12), guest],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: signUp),
                            const SizedBox(width: 12),
                            Expanded(child: guest),
                          ],
                        );
                      },
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
