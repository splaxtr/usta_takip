import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/services/auth_lock_service.dart';
import 'app_lock_state.dart';

class LockCubit extends Cubit<AppLockState> {
  LockCubit(this._authLockService) : super(AppLockState.initial());

  final AuthLockService _authLockService;

  Future<void> initialize() async {
    final enabled = await _authLockService.isLockEnabled();
    emit(state.copyWith(isLocked: enabled, lockEnabled: enabled));
  }

  Future<void> unlockWithPin(String pin) async {
    final success = await _authLockService.unlockWithPin(pin);
    if (success) {
      emit(state.copyWith(isLocked: false, errorMessage: null));
    } else {
      emit(state.copyWith(errorMessage: 'Yanlış PIN'));
    }
  }

  Future<void> unlockWithBiometrics() async {
    final success = await _authLockService.unlockWithBiometrics();
    if (success) {
      emit(state.copyWith(isLocked: false, errorMessage: null));
    } else {
      emit(state.copyWith(errorMessage: 'Biyometrik doğrulama başarısız'));
    }
  }

  Future<void> enableLock(String pin) async {
    await _authLockService.enableLock(pin);
    emit(state.copyWith(isLocked: true, lockEnabled: true));
  }

  Future<void> disableLock() async {
    await _authLockService.disableLock();
    emit(state.copyWith(isLocked: false, lockEnabled: false));
  }
}
