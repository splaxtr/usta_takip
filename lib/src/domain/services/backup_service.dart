abstract class BackupService {
  Future<void> backupNow();
  Future<void> restoreLatest();
  Future<DateTime?> lastBackupTime();
}
