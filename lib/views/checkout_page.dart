import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.controller});

  final StoreController controller;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _paypalEmailController = TextEditingController();
  final _appleIdController = TextEditingController();

  String _paymentMethod = 'Carte bancaire';
  bool _isSubmitting = false;

  bool _isEmailValid(String value) {
    return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$").hasMatch(value.trim());
  }

  bool _isCardNumberValid(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    return normalized.length >= 12 && RegExp(r'^\d{12,19}$').hasMatch(normalized);
  }

  bool _isExpirationValid(String value) {
    return RegExp(r'^(0[1-9]|1[0-2])\/(\d{2}|\d{4})$').hasMatch(value.trim());
  }

  bool _isValidCvc(String value) => RegExp(r'^\d{3,4}$').hasMatch(value.trim());

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _paypalEmailController.dispose();
    _appleIdController.dispose();
    super.dispose();
  }

  Widget _buildPaymentFields() {
    switch (_paymentMethod) {
      case 'PayPal':
        return Column(
          children: [
            TextFormField(
              controller: _paypalEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Adresse e-mail PayPal'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Adresse e-mail PayPal requise';
                if (!_isEmailValid(value)) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'La validation du paiement se fait via votre compte PayPal sécurisé.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        );
      case 'Apple Pay':
        return Column(
          children: [
            TextFormField(
              controller: _appleIdController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Compte Apple Pay',
                hintText: 'Email ou numéro associé à votre appareil',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Le compte Apple Pay est requis';
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Le paiement est vérifié sur votre appareil ou via votre compte Apple sécurisé.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        );
      case 'Carte bancaire':
      default:
        return Column(
          children: [
            TextFormField(
              controller: _cardNameController,
              decoration: const InputDecoration(labelText: 'Nom du titulaire'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Le titulaire est requis';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Numéro de carte', hintText: '4242 4242 4242 4242'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Numéro de carte requis';
                if (!_isCardNumberValid(value)) return 'Numéro invalide';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(labelText: 'Expiration', hintText: 'MM/AA'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Date requise';
                      if (!_isExpirationValid(value)) return 'Date invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvcController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'CVC'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'CVC requis';
                      if (!_isValidCvc(value)) return 'CVC invalide';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final reference = widget.controller.placeOrder();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationPage(controller: widget.controller, reference: reference),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final items = controller.cartItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: ContentWidth(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepHeader(),
              const SizedBox(height: 20),
              _Card(
                title: 'Livraison',
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) return 'Nom requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Adresse e-mail'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email requis';
                      if (!_isEmailValid(value)) return 'Format email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Adresse de livraison'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Adresse requise';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'Ville'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Ville requise';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Code postal'),
                          validator: (value) {
                            if (value == null || !RegExp(r'^\d{4,6}$').hasMatch(value.trim())) return 'Invalide';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Téléphone requis';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Paiement',
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Carte bancaire', 'PayPal', 'Apple Pay'].map((method) {
                      final active = _paymentMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: active,
                        onSelected: (_) => setState(() => _paymentMethod = method),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: active ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentFields(),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Résumé',
                children: [
                  if (items.isEmpty)
                    const Text('Aucun article dans le panier.')
                  else
                    ...items.map((product) {
                      final quantity = controller.quantityFor(product);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${product.name.split(' · ').first} x$quantity',
                                style: const TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                            Text('${(product.price * quantity).toStringAsFixed(0)} €'),
                          ],
                        ),
                      );
                    }),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sous-total', style: TextStyle(color: AppColors.textSecondary)),
                      Text('${controller.cartSubtotal.toStringAsFixed(2)} €'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Livraison', style: TextStyle(color: AppColors.textSecondary)),
                      Text('${controller.shippingCost.toStringAsFixed(2)} €'),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Payer maintenant',
                  loading: _isSubmitting,
                  onPressed: controller.isCartEmpty || _isSubmitting ? null : _submit,
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

class _StepHeader extends StatelessWidget {
  const _StepHeader();

  @override
  Widget build(BuildContext context) {
    const steps = ['Panier', 'Livraison & paiement', 'Confirmation'];
    return Row(
      children: List.generate(steps.length, (index) {
        final active = index == 1;
        final done = index < 1;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: active || done ? AppColors.primary : AppColors.border,
                child: done
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text('${index + 1}', style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.textSecondary)),
              ),
              if (index != steps.length - 1)
                Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border)),
            ],
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
