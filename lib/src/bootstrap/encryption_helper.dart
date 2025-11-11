import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class EncryptionHelper {
  EncryptionHelper({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keyName = 'usta_takip_hive_aes_key';

  Future<List<int>> loadKey() async {
    final stored = await _storage.read(key: _keyName);
    if (stored != null) {
      return base64Decode(stored);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }
}
