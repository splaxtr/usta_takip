import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive test ortamı için yardımcı sınıf
class HiveTestHelper {
  static Directory? _tempDir;
  static final List<String> _openBoxes = [];

  /// Test için Hive'ı başlatır
  static Future<void> initHive() async {
    _tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(_tempDir!.path);
  }

  /// Belirtilen isimde bir box açar
  static Future<Box> openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).clear();
      return Hive.box(boxName);
    }
    final box = await Hive.openBox(boxName);
    _openBoxes.add(boxName);
    return box;
  }

  /// Belirtilen box'a test verisi ekler
  static Future<int> addData(String boxName, Map<String, dynamic> data) async {
    final box = await openBox(boxName);
    return await box.add(data);
  }

  /// Tüm box'ları kapatır ve Hive'ı temizler
  static Future<void> closeHive() async {
    await Hive.close();
    _openBoxes.clear();
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
      _tempDir = null;
    }
  }

  /// Tüm açık box'ları temizler
  static Future<void> clearAllBoxes() async {
    for (final boxName in _openBoxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      }
    }
  }
}
