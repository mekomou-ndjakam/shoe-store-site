import 'package:aurora_store/services/account_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AuthFailure> failureOf(Future<void> Function() action) async {
    try {
      await action();
    } on AuthFailure catch (failure) {
      return failure;
    }
    fail('AuthFailure attendue');
  }

  test('un compte créé est retrouvé après une nouvelle visite', () async {
    await AccountService().signUp(name: 'Jessica N', email: 'Jess@Example.com', password: 'motdepasse1');
    await AccountService().logout();

    final account = await AccountService().login(email: 'jess@example.com ', password: 'motdepasse1');
    expect(account.name, 'Jessica N');
    expect((await AccountService().currentAccount())?.email, 'jess@example.com');
  });

  test('signale un compte déjà existant', () async {
    final service = AccountService();
    await service.signUp(name: 'A', email: 'a@b.fr', password: 'motdepasse1');
    final failure = await failureOf(() => service.signUp(name: 'A', email: 'A@B.fr', password: 'autre12345'));
    expect(failure.accountExists, isTrue);
    expect(failure.field, AuthField.email);
  });

  test('distingue e-mail inconnu et mot de passe faux', () async {
    final service = AccountService();
    await service.signUp(name: 'A', email: 'a@b.fr', password: 'motdepasse1');
    await service.logout();

    final unknown = await failureOf(() => service.login(email: 'x@b.fr', password: 'motdepasse1'));
    expect(unknown.field, AuthField.email);

    final wrong = await failureOf(() => service.login(email: 'a@b.fr', password: 'mauvais123'));
    expect(wrong.field, AuthField.password);
    expect(await service.currentAccount(), isNull);
  });

  test('met à jour le profil et change le mot de passe', () async {
    final service = AccountService();
    await service.signUp(name: 'A', email: 'a@b.fr', password: 'motdepasse1');
    final updated = await service.update('a@b.fr', {
      'phone': '0600000000',
      'address': const ShippingAddress(line: '1 rue X', city: 'Paris', postalCode: '75001').toJson(),
    });
    expect(updated.address?.city, 'Paris');

    final badCurrent = await failureOf(
      () => service.changePassword(email: 'a@b.fr', currentPassword: 'faux', newPassword: 'nouveau123'),
    );
    expect(badCurrent.field, AuthField.password);

    await service.changePassword(email: 'a@b.fr', currentPassword: 'motdepasse1', newPassword: 'nouveau123');
    await service.logout();
    await service.login(email: 'a@b.fr', password: 'nouveau123');
  });
}
