import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/employee.dart';
import '../../data/models/expense.dart';
import '../../data/models/project.dart';
import '../../data/models/wage_entry.dart';
import '../../domain/services/backup_service.dart';

class LocalBackupService implements BackupService {
  LocalBackupService({
    required Box<Project> projectBox,
    required Box<Employee> employeeBox,
    required Box<WageEntry> wageBox,
    required Box<Expense> expenseBox,
    required Box settingsBox,
    required List<int> encryptionKey,
  })  : _projectBox = projectBox,
        _employeeBox = employeeBox,
        _wageBox = wageBox,
        _expenseBox = expenseBox,
        _settingsBox = settingsBox,
        _encrypter = Encrypter(
          AES(Key(Uint8List.fromList(encryptionKey)), mode: AESMode.cbc),
        ),
        _iv = IV(Uint8List.fromList(encryptionKey.take(16).toList()));

  final Box<Project> _projectBox;
  final Box<Employee> _employeeBox;
  final Box<WageEntry> _wageBox;
  final Box<Expense> _expenseBox;
  final Box _settingsBox;

  final Encrypter _encrypter;
  final IV _iv;

  static const _lastBackupKey = 'lastBackup';

  @override
  Future<void> backupNow() async {
    final payload = {
      'projects': _projectBox.values.map((e) => e.toJson()).toList(),
      'employees': _employeeBox.values.map((e) => e.toJson()).toList(),
      'wages': _wageBox.values.map((e) => e.toJson()).toList(),
      'expenses': _expenseBox.values.map((e) => e.toJson()).toList(),
    };
    final jsonStr = jsonEncode(payload);
    final encrypted = _encrypter.encrypt(jsonStr, iv: _iv);
    final dir = await _backupDirectory();
    final file = File(
      '${dir.path}/usta_takip_backup_${DateTime.now().millisecondsSinceEpoch}.bin',
    );
    await file.writeAsBytes(encrypted.bytes);
    await _settingsBox.put(_lastBackupKey, DateTime.now().toIso8601String());
  }

  @override
  Future<void> restoreLatest() async {
    final dir = await _backupDirectory();
    if (!await dir.exists()) return;
    final backups = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.bin'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    if (backups.isEmpty) return;
    final latest = backups.first;
    final bytes = await latest.readAsBytes();
    final decrypted = _encrypter.decrypt(Encrypted(bytes), iv: _iv);
    final data = jsonDecode(decrypted) as Map<String, dynamic>;

    await _restoreBox<Project>(
      _projectBox,
      (json) => Project.fromJson(json as Map<String, dynamic>),
      data['projects'] as List<dynamic>? ?? const [],
    );
    await _restoreBox<Employee>(
      _employeeBox,
      (json) => Employee.fromJson(json as Map<String, dynamic>),
      data['employees'] as List<dynamic>? ?? const [],
    );
    await _restoreBox<WageEntry>(
      _wageBox,
      (json) => WageEntry.fromJson(json as Map<String, dynamic>),
      data['wages'] as List<dynamic>? ?? const [],
    );
    await _restoreBox<Expense>(
      _expenseBox,
      (json) => Expense.fromJson(json as Map<String, dynamic>),
      data['expenses'] as List<dynamic>? ?? const [],
    );
  }

  @override
  Future<DateTime?> lastBackupTime() async {
    final stored = _settingsBox.get(_lastBackupKey) as String?;
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }

  Future<Directory> _backupDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/usta_takip_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> _restoreBox<T>(
    Box<T> box,
    T Function(Map<String, dynamic>) fromJson,
    List<dynamic> payload,
  ) async {
    await box.clear();
    for (final entry in payload) {
      final map = entry as Map<String, dynamic>;
      final obj = fromJson(map);
      await box.put(map['id'], obj);
    }
  }
}
