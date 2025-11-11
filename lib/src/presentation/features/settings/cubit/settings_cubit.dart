import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/services/auth_lock_service.dart';
import '../../../../domain/services/backup_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._authLockService, this._backupService)
      : super(const SettingsState());

  final AuthLockService _authLockService;
  final BackupService _backupService;

  Future<void> load() async {
    final enabled = await _authLockService.isLockEnabled();
    final lastBackup = await _backupService.lastBackupTime();
    emit(
      state.copyWith(
        lockEnabled: enabled,
        lastBackup: lastBackup,
      ),
    );
  }

  Future<void> enableLock(String pin) async {
    emit(state.copyWith(isProcessing: true));
    await _authLockService.enableLock(pin);
    emit(
      state.copyWith(
        isProcessing: false,
        lockEnabled: true,
        statusMessage: 'PIN kilidi etkin',
      ),
    );
  }

  Future<void> disableLock() async {
    emit(state.copyWith(isProcessing: true));
    await _authLockService.disableLock();
    emit(
      state.copyWith(
        isProcessing: false,
        lockEnabled: false,
        statusMessage: 'PIN kilidi kapandı',
      ),
    );
  }

  Future<void> backupNow() async {
    emit(state.copyWith(isProcessing: true, statusMessage: null));
    await _backupService.backupNow();
    final lastBackup = await _backupService.lastBackupTime();
    emit(
      state.copyWith(
        isProcessing: false,
        lastBackup: lastBackup,
        statusMessage: 'Yedekleme tamamlandı',
      ),
    );
  }

  Future<void> restoreBackup() async {
    emit(state.copyWith(isProcessing: true, statusMessage: null));
    await _backupService.restoreLatest();
    emit(
      state.copyWith(
        isProcessing: false,
        statusMessage: 'Yedek geri yüklendi',
      ),
    );
  }
}
