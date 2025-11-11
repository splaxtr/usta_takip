abstract class AuthLockService {
  Future<bool> isLockEnabled();
  Future<void> enableLock(String pin);
  Future<void> disableLock();
  Future<bool> unlockWithPin(String pin);
  Future<bool> unlockWithBiometrics();
  Future<void> updatePin(String newPin);
}
