import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.controller, this.startInSignUp = false});

  final StoreController controller;
  final bool startInSignUp;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isSignUp = widget.startInSignUp;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String value) {
    return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$").hasMatch(value.trim());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp) {
      widget.controller.signUp(name: _nameController.text, email: _emailController.text);
    } else {
      widget.controller.login(email: _emailController.text);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isSignUp ? 'Créer un compte' : 'Se connecter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: ContentWidth(
          maxWidth: 480,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  _isSignUp ? 'Bienvenue chez AURORA' : 'Content de vous revoir',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Créez votre compte pour suivre vos commandes et retrouver vos favoris.'
                      : 'Connectez-vous pour retrouver votre panier et vos commandes.',
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) return 'Nom requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],
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
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: _isSignUp ? 'Créer mon compte' : 'Se connecter',
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? 'Déjà un compte ? Se connecter'
                          : "Pas encore de compte ? S'inscrire",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
