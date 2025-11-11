import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.lockEnabled = false,
    this.isProcessing = false,
    this.lastBackup,
    this.statusMessage,
  });

  final bool lockEnabled;
  final bool isProcessing;
  final DateTime? lastBackup;
  final String? statusMessage;

  SettingsState copyWith({
    bool? lockEnabled,
    bool? isProcessing,
    DateTime? lastBackup,
    String? statusMessage,
  }) {
    return SettingsState(
      lockEnabled: lockEnabled ?? this.lockEnabled,
      isProcessing: isProcessing ?? this.isProcessing,
      lastBackup: lastBackup ?? this.lastBackup,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        lockEnabled,
        isProcessing,
        lastBackup,
        statusMessage,
      ];
}
