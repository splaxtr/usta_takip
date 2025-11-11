import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/services/auth_lock_service.dart';

class SecureStorageAuthLockService implements AuthLockService {
  SecureStorageAuthLockService({
    FlutterSecureStorage? storage,
    LocalAuthentication? localAuth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _lockKey = 'lock_enabled';
  static const _pinKey = 'lock_pin_hash';

  @override
  Future<void> enableLock(String pin) async {
    await _storage.write(key: _pinKey, value: _hash(pin));
    await _storage.write(key: _lockKey, value: 'true');
  }

  @override
  Future<void> disableLock() async {
    await _storage.delete(key: _lockKey);
  }

  @override
  Future<bool> isLockEnabled() async {
    final value = await _storage.read(key: _lockKey);
    return value == 'true';
  }

  @override
  Future<bool> unlockWithPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  @override
  Future<bool> unlockWithBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) return false;
    return _localAuth.authenticate(
      localizedReason: 'Uygulamayı açmak için kilidi doğrulayın',
      options: const AuthenticationOptions(
        sensitiveTransaction: true,
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }

  @override
  Future<void> updatePin(String newPin) async {
    await _storage.write(key: _pinKey, value: _hash(newPin));
  }

  String _hash(String input) {
    final digest = sha256.convert(utf8.encode(input));
    return digest.toString();
  }
}
