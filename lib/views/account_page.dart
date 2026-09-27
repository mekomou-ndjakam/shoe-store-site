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

const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String _formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

class _SignedInAccount extends StatelessWidget {
  const _SignedInAccount({required this.controller});

  final StoreController controller;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final name = controller.userName?.trim().isNotEmpty == true ? controller.userName! : 'Client AURORA';
    final firstName = name.split(RegExp(r'\s+')).first;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final since = controller.memberSince;
    final orders = controller.orders;
    final address = controller.userAddress;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  initials.isEmpty ? 'A' : initials,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour $firstName',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  if (controller.userEmail != null)
                    Text(controller.userEmail!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (since != null)
                    Text(
                      'Membre depuis le ${_formatDate(since)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.receipt_long_outlined,
                value: '${orders.length}',
                label: orders.length > 1 ? 'Commandes' : 'Commande',
                onTap: () => _push(context, _OrdersPage(controller: controller)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.favorite_border_rounded,
                value: '${controller.favoriteProducts.length}',
                label: 'Favoris',
                onTap: () => controller.setTab(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.shopping_bag_outlined,
                value: '${controller.cartCount}',
                label: 'Panier',
                onTap: () => controller.setTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Mes achats'),
        _MenuGroup(
          children: [
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'Mes commandes',
              subtitle: orders.isEmpty ? 'Aucune commande pour le moment' : 'Dernière le ${_formatDate(orders.first.date)}',
              onTap: () => _push(context, _OrdersPage(controller: controller)),
            ),
            _MenuItem(
              icon: Icons.favorite_border_rounded,
              title: 'Mes favoris',
              onTap: () => controller.setTab(3),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Mon profil'),
        _MenuGroup(
          children: [
            _MenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Mes informations',
              subtitle: controller.userPhone?.isNotEmpty == true ? '$name · ${controller.userPhone}' : name,
              onTap: () => _push(context, _ProfilePage(controller: controller)),
            ),
            _MenuItem(
              icon: Icons.location_on_outlined,
              title: 'Adresse de livraison',
              subtitle: address == null ? 'Ajoutez une adresse pour commander plus vite' : address.toString(),
              onTap: () => _push(context, _AddressPage(controller: controller)),
            ),
            _MenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Changer le mot de passe',
              onTap: () => showDialog(
                context: context,
                builder: (_) => _ChangePasswordDialog(controller: controller),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label, required this.onTap});

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title, this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ---- Sub-pages --------------------------------------------------------------

class _OrdersPage extends StatelessWidget {
  const _OrdersPage({required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    final orders = controller.orders;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ContentWidth(
        child: orders.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune commande pour le moment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vos commandes passées avec ce compte apparaîtront ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Découvrir la boutique',
                        onPressed: () {
                          controller.setTab(1);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.reference,
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(order.date)} · ${order.itemCount} article${order.itemCount > 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${order.total.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Shared scaffold for the small edit forms of the account area.
class _EditPage extends StatefulWidget {
  const _EditPage({required this.title, required this.fields, required this.onSave});

  final String title;
  final List<Widget> fields;
  final Future<void> Function() onSave;

  @override
  State<_EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<_EditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modifications enregistrées')));
      Navigator.of(context).pop();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: ContentWidth(
          maxWidth: 480,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final field in widget.fields) ...[field, const SizedBox(height: 14)],
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                GradientButton(label: 'Enregistrer', loading: _saving, onPressed: _saving ? null : _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.controller});

  final StoreController controller;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  late final _name = TextEditingController(text: widget.controller.userName);
  late final _phone = TextEditingController(text: widget.controller.userPhone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPage(
      title: 'Mes informations',
      onSave: () => widget.controller.updateProfile(name: _name.text, phone: _phone.text),
      fields: [
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nom complet'),
          validator: (value) => value == null || value.trim().length < 2 ? 'Nom requis' : null,
        ),
        TextFormField(
          initialValue: widget.controller.userEmail,
          enabled: false,
          decoration: const InputDecoration(labelText: 'Adresse e-mail'),
        ),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Téléphone (facultatif)'),
        ),
      ],
    );
  }
}

class _AddressPage extends StatefulWidget {
  const _AddressPage({required this.controller});

  final StoreController controller;

  @override
  State<_AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<_AddressPage> {
  late final _line = TextEditingController(text: widget.controller.userAddress?.line);
  late final _city = TextEditingController(text: widget.controller.userAddress?.city);
  late final _postalCode = TextEditingController(text: widget.controller.userAddress?.postalCode);

  @override
  void dispose() {
    _line.dispose();
    _city.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPage(
      title: 'Adresse de livraison',
      onSave: () => widget.controller.updateAddress(
        ShippingAddress(line: _line.text.trim(), city: _city.text.trim(), postalCode: _postalCode.text.trim()),
      ),
      fields: [
        TextFormField(
          controller: _line,
          decoration: const InputDecoration(labelText: 'Adresse'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Adresse requise' : null,
        ),
        TextFormField(
          controller: _postalCode,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Code postal'),
          validator: (value) => value == null || !RegExp(r'^\d{4,6}$').hasMatch(value.trim()) ? 'Code postal invalide' : null,
        ),
        TextFormField(
          controller: _city,
          decoration: const InputDecoration(labelText: 'Ville'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Ville requise' : null,
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.controller});

  final StoreController controller;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.changePassword(currentPassword: _current.text, newPassword: _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe modifié')));
      Navigator.of(context).pop();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer le mot de passe'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
              validator: (value) => value == null || value.isEmpty ? 'Mot de passe actuel requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              validator: (value) => value == null || value.length < 8 ? '8 caractères minimum' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer'),
              validator: (value) => value != _password.text ? 'Les mots de passe ne correspondent pas' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
