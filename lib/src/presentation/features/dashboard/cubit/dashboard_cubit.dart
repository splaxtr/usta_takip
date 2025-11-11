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

      emit(
        state.copyWith(
          isLoading: false,
          totalIncome: summary.totalIncome,
          paidExpenses: summary.paidExpenses,
          pendingWages: summary.pendingWages,
          outstandingPayments: summary.outstandingPatronPayments,
          activeProjects: summary.activeProjects,
          lastBackup: lastBackup ?? summary.lastBackup,
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
}
