import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';
import 'auth_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.controller});

  final StoreController controller;

  void _openAuth(BuildContext context, {bool startInSignUp = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthPage(controller: controller, startInSignUp: startInSignUp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          child: ContentWidth(
            child: controller.isAuthenticated
                ? _SignedInAccount(controller: controller)
                : _SignedOutAccount(
                    onLogin: () => _openAuth(context),
                    onSignUp: () => _openAuth(context, startInSignUp: true),
                  ),
          ),
        );
      },
    );
  }
}

class _SignedOutAccount extends StatelessWidget {
  const _SignedOutAccount({required this.onLogin, required this.onSignUp});

  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre espace AURORA',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connectez-vous pour suivre vos commandes, retrouver vos favoris et accélérer vos achats.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, child: GradientButton(label: 'Se connecter', onPressed: onLogin)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onSignUp, child: const Text('Créer un compte')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInAccount extends StatelessWidget {
  const _SignedInAccount({required this.controller});

  final StoreController controller;

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Cette fonctionnalité arrive bientôt, une fois le compte client connecté à nos serveurs.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Compris')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = controller.userName?.trim().isNotEmpty == true ? controller.userName! : 'Client AURORA';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    final items = [
      (Icons.receipt_long_outlined, 'Mes commandes'),
      (Icons.assignment_return_outlined, 'Mes retours'),
      (Icons.workspace_premium_outlined, 'AURORA Premium'),
      (Icons.help_outline_rounded, "Besoin d'aide ?"),
      (Icons.person_outline_rounded, 'Mes informations'),
      (Icons.lock_outline_rounded, 'Changer le mot de passe'),
      (Icons.location_on_outlined, "Carnet d'adresses"),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'A' : initials,
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bonjour,', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              Text(
                name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              if (controller.userEmail != null) ...[
                const SizedBox(height: 4),
                Text(controller.userEmail!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.$1, color: AppColors.textPrimary),
                    title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    onTap: () => _showComingSoon(context, item.$2),
                  ),
                  if (!isLast) const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            label: const Text('Se déconnecter', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}
