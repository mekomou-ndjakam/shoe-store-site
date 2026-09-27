import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthField { email, password }

/// An authentication error with a message ready to display. [field] tells the
/// form which input to highlight.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.field, this.accountExists = false});

  final String message;
  final AuthField? field;
  final bool accountExists;

  @override
  String toString() => message;
}

class ShippingAddress {
  const ShippingAddress({required this.line, required this.city, required this.postalCode});

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
        line: json['line'] as String? ?? '',
        city: json['city'] as String? ?? '',
        postalCode: json['postal_code'] as String? ?? '',
      );

  final String line;
  final String city;
  final String postalCode;

  Map<String, dynamic> toJson() => {'line': line, 'city': city, 'postal_code': postalCode};

  @override
  String toString() => '$line, $postalCode $city';
}

class OrderSummary {
  const OrderSummary({required this.reference, required this.date, required this.total, required this.itemCount});

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
        reference: json['reference'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      );

  final String reference;
  final DateTime date;
  final double total;
  final int itemCount;

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'date': date.toIso8601String(),
        'total': total,
        'item_count': itemCount,
      };
}

/// A customer account as seen by the app (never includes the password).
class Account {
  const Account({
    required this.email,
    required this.name,
    required this.createdAt,
    this.phone,
    this.address,
    this.orders = const [],
  });

  final String email;
  final String name;
  final DateTime createdAt;
  final String? phone;
  final ShippingAddress? address;
  final List<OrderSummary> orders;
}

/// Stores customer accounts in the browser's local storage.
///
/// Accounts survive page reloads and browser restarts on the same device, but
/// are not shared between devices: replace this class with calls to a server
/// when the site needs real online accounts.
class AccountService {
  static const _usersKey = 'aurora.users';
  static const _sessionKey = 'aurora.session';
  static const _hashRounds = 10000;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, Map<String, dynamic>>> _readUsers() async {
    final raw = (await _prefs).getString(_usersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((email, value) => MapEntry(email, Map<String, dynamic>.from(value as Map)));
  }

  Future<void> _writeUsers(Map<String, Map<String, dynamic>> users) async {
    await (await _prefs).setString(_usersKey, jsonEncode(users));
  }

  String _normalize(String email) => email.trim().toLowerCase();

  String _newSalt() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  String _hash(String password, String salt) {
    List<int> digest = utf8.encode('$salt:$password');
    for (var i = 0; i < _hashRounds; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Url.encode(digest);
  }

  Account _toAccount(String email, Map<String, dynamic> json) => Account(
        email: email,
        name: json['name'] as String? ?? email.split('@').first,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        phone: json['phone'] as String?,
        address: json['address'] is Map
            ? ShippingAddress.fromJson(Map<String, dynamic>.from(json['address'] as Map))
            : null,
        orders: json['orders'] is List
            ? (json['orders'] as List)
                .whereType<Map>()
                .map((order) => OrderSummary.fromJson(Map<String, dynamic>.from(order)))
                .toList()
            : const [],
      );

  /// The account of the signed-in customer, if any.
  Future<Account?> currentAccount() async {
    try {
      final email = (await _prefs).getString(_sessionKey);
      if (email == null) return null;
      final user = (await _readUsers())[email];
      return user == null ? null : _toAccount(email, user);
    } catch (_) {
      return null;
    }
  }

  Future<Account> signUp({required String name, required String email, required String password}) async {
    final key = _normalize(email);
    final users = await _readUsers();
    if (users.containsKey(key)) {
      throw const AuthFailure(
        'Un compte existe déjà avec cette adresse e-mail. Connectez-vous.',
        field: AuthField.email,
        accountExists: true,
      );
    }
    final salt = _newSalt();
    users[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
      'created_at': DateTime.now().toIso8601String(),
    };
    await _writeUsers(users);
    await (await _prefs).setString(_sessionKey, key);
    return _toAccount(key, users[key]!);
  }

  Future<Account> login({required String email, required String password}) async {
    final key = _normalize(email);
    final user = (await _readUsers())[key];
    if (user == null) {
      throw const AuthFailure('Aucun compte n’est associé à cette adresse e-mail.', field: AuthField.email);
    }
    if (_hash(password, user['salt'] as String) != user['hash']) {
      throw const AuthFailure('Mot de passe incorrect.', field: AuthField.password);
    }
    await (await _prefs).setString(_sessionKey, key);
    return _toAccount(key, user);
  }

  Future<void> logout() async {
    await (await _prefs).remove(_sessionKey);
  }

  Future<void> changePassword({required String email, required String currentPassword, required String newPassword}) async {
    final users = await _readUsers();
    final user = users[email];
    if (user == null) throw const AuthFailure('Session expirée. Reconnectez-vous.');
    if (_hash(currentPassword, user['salt'] as String) != user['hash']) {
      throw const AuthFailure('Mot de passe actuel incorrect.', field: AuthField.password);
    }
    if (currentPassword == newPassword) {
      throw const AuthFailure('Le nouveau mot de passe doit être différent de l’ancien.');
    }
    final salt = _newSalt();
    user
      ..['salt'] = salt
      ..['hash'] = _hash(newPassword, salt);
    await _writeUsers(users);
  }

  /// Merges [fields] into the stored profile and returns the updated account.
  Future<Account> update(String email, Map<String, dynamic> fields) async {
    final users = await _readUsers();
    final user = users[email];
    if (user == null) throw const AuthFailure('Session expirée. Reconnectez-vous.');
    user.addAll(fields);
    await _writeUsers(users);
    return _toAccount(email, user);
  }
}
