import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/content_width.dart';
import '../widgets/gradient_button.dart';

/// Sign-in / sign-up screen. Pops with `true` once the user is signed in.
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
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _emailError;
  String? _passwordError;
  bool _accountExists = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String value) {
    return RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$").hasMatch(value.trim());
  }

  void _clearServerErrors() {
    _errorMessage = null;
    _emailError = null;
    _passwordError = null;
    _accountExists = false;
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _clearServerErrors();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit() async {
    setState(_clearServerErrors);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      if (_isSignUp) {
        await widget.controller.signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.controller.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _accountExists = failure.accountExists;
        switch (failure.field) {
          case AuthField.email:
            _emailError = failure.message;
          case AuthField.password:
            _passwordError = failure.message;
          case null:
            _errorMessage = failure.message;
        }
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
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
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail',
                    errorText: _emailError,
                    errorMaxLines: 3,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email requis';
                    if (!_isEmailValid(value)) return 'Format email invalide';
                    return null;
                  },
                ),
                if (_accountExists)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _toggleMode,
                      child: const Text('Se connecter avec cette adresse', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: [_isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                  onChanged: (_) {
                    if (_passwordError != null) setState(() => _passwordError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    helperText: _isSignUp ? '8 caractères minimum' : null,
                    errorText: _passwordError,
                    errorMaxLines: 3,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mot de passe requis';
                    if (_isSignUp && value.length < 8) return '8 caractères minimum';
                    return null;
                  },
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: _isSignUp ? 'Créer mon compte' : 'Se connecter',
                    loading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _toggleMode,
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
