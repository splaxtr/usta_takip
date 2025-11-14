import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/ledger_repository.dart';
import '../../../../domain/services/backup_service.dart';
import '../../../../domain/usecases/record_work_day.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required LedgerRepository ledgerRepository,
    required BackupService backupService,
    required RecordWorkDay recordWorkDay,
  })  : _ledgerRepository = ledgerRepository,
        _backupService = backupService,
        _recordWorkDay = recordWorkDay,
        super(const DashboardState());

  final LedgerRepository _ledgerRepository;
  final BackupService _backupService;
  final RecordWorkDay _recordWorkDay;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, resetError: true));
    try {
      final summary = await _ledgerRepository.loadSummary();
      final lastBackup = await _backupService.lastBackupTime();
      final weeklyTrend = _generateWeeklyTrend(summary);
      final reminders = _buildReminders(summary);

      emit(
        state.copyWith(
          isLoading: false,
          totalIncome: summary.totalIncome,
          totalExpenses: summary.paidExpenses,
          pendingWages: summary.pendingWages,
          outstandingPayments: summary.outstandingPatronPayments,
          activeProjects: summary.activeProjects,
          lastBackup: lastBackup ?? summary.lastBackup,
          weeklyTrend: weeklyTrend,
          reminders: reminders,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> recordWorkDay(RecordWorkDayParams params) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _recordWorkDay(params);
      await refresh();
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  List<double> _generateWeeklyTrend(summary) {
    final base = summary.totalIncome > 0
        ? summary.totalIncome / 7
        : (summary.paidExpenses + 1) / 7;
    return List<double>.generate(
      7,
      (index) => ((base * (0.7 + (index * 0.07))) +
              (summary.pendingWages * 0.05))
          .clamp(0, double.infinity),
    );
  }

  List<String> _buildReminders(summary) {
    final reminders = <String>[];
    if (summary.pendingWages > 0) {
      reminders
          .add('Ödenmemiş yevmiye: ${summary.pendingWages.toStringAsFixed(0)}₺');
    }
    if (summary.outstandingPatronPayments > 0) {
      reminders.add(
        'Patron ödemesi bekleniyor: ${summary.outstandingPatronPayments.toStringAsFixed(0)}₺',
      );
    }
    if (summary.activeProjects == 0) {
      reminders.add('Yeni proje ekleyin ve çalışmaya başlayın.');
    }
    return reminders.isEmpty ? ['Tüm kayıtlar güncel görünüyor.'] : reminders;
  }
}
