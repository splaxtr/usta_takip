import 'package:equatable/equatable.dart';

class AppLockState extends Equatable {
  const AppLockState({
    required this.isLocked,
    required this.lockEnabled,
    this.errorMessage,
  });

  factory AppLockState.initial() => const AppLockState(
        isLocked: false,
        lockEnabled: false,
      );

  final bool isLocked;
  final bool lockEnabled;
  final String? errorMessage;

  AppLockState copyWith({
    bool? isLocked,
    bool? lockEnabled,
    String? errorMessage,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLocked, lockEnabled, errorMessage];
}
