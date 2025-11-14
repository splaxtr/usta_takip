import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/services/backup_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._backupService) : super(const SettingsState());

  final BackupService _backupService;

  Future<void> load() async {
    final lastBackup = await _backupService.lastBackupTime();
    emit(
      state.copyWith(
        lastBackup: lastBackup,
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
