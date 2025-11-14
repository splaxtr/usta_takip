import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isProcessing = false,
    this.lastBackup,
    this.statusMessage,
  });

  final bool isProcessing;
  final DateTime? lastBackup;
  final String? statusMessage;

  SettingsState copyWith({
    bool? isProcessing,
    DateTime? lastBackup,
    String? statusMessage,
  }) {
    return SettingsState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastBackup: lastBackup ?? this.lastBackup,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        isProcessing,
        lastBackup,
        statusMessage,
      ];
}
