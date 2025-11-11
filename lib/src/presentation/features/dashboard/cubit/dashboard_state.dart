import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.totalIncome = 0,
    this.paidExpenses = 0,
    this.pendingWages = 0,
    this.activeProjects = 0,
    this.lastBackup,
  });

  final bool isLoading;
  final String? errorMessage;
  final double totalIncome;
  final double paidExpenses;
  final double pendingWages;
  final int activeProjects;
  final DateTime? lastBackup;

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? totalIncome,
    double? paidExpenses,
    double? pendingWages,
    int? activeProjects,
    DateTime? lastBackup,
    bool resetError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
      totalIncome: totalIncome ?? this.totalIncome,
      paidExpenses: paidExpenses ?? this.paidExpenses,
      pendingWages: pendingWages ?? this.pendingWages,
      activeProjects: activeProjects ?? this.activeProjects,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        totalIncome,
        paidExpenses,
        pendingWages,
        activeProjects,
        lastBackup,
      ];
}
