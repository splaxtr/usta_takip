import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/expense_repository.dart';
import '../../../../domain/repositories/project_repository.dart';
import '../../../../domain/repositories/wage_repository.dart';
import '../../../../domain/usecases/record_work_day.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required ProjectRepository projectRepository,
    required ExpenseRepository expenseRepository,
    required WageRepository wageRepository,
    required RecordWorkDay recordWorkDay,
  })  : _projectRepository = projectRepository,
        _expenseRepository = expenseRepository,
        _wageRepository = wageRepository,
        _recordWorkDay = recordWorkDay,
        super(const DashboardState());

  final ProjectRepository _projectRepository;
  final ExpenseRepository _expenseRepository;
  final WageRepository _wageRepository;
  final RecordWorkDay _recordWorkDay;

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, resetError: true));
    try {
      final projects = await _projectRepository.getAll();
      final expenses = await _expenseRepository.getAll();
      final pendingWages = await _wageRepository.getPendingTotal();

      final totalIncome = projects.fold<double>(
        0,
        (sum, project) => sum + project.totalBudget,
      );
      final paidExpenses = expenses
          .where((expense) => expense.isPaid)
          .fold<double>(0, (sum, expense) => sum + expense.amount);

      emit(
        state.copyWith(
          isLoading: false,
          totalIncome: totalIncome,
          paidExpenses: paidExpenses,
          pendingWages: pendingWages,
          activeProjects: projects.length,
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
