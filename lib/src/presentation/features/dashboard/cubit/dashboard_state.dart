import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.pendingWages = 0,
    this.outstandingPayments = 0,
    this.activeProjects = 0,
    this.lastBackup,
    this.weeklyTrend = const [],
    this.reminders = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final double totalIncome;
  final double totalExpenses;
  final double pendingWages;
  final double outstandingPayments;
  final int activeProjects;
  final DateTime? lastBackup;
  final List<double> weeklyTrend;
  final List<String> reminders;

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? totalIncome,
    double? totalExpenses,
    double? pendingWages,
    double? outstandingPayments,
    int? activeProjects,
    DateTime? lastBackup,
    List<double>? weeklyTrend,
    List<String>? reminders,
    bool resetError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      pendingWages: pendingWages ?? this.pendingWages,
      outstandingPayments: outstandingPayments ?? this.outstandingPayments,
      activeProjects: activeProjects ?? this.activeProjects,
      lastBackup: lastBackup ?? this.lastBackup,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        totalIncome,
        totalExpenses,
        pendingWages,
        outstandingPayments,
        activeProjects,
        lastBackup,
        weeklyTrend,
        reminders,
      ];
}
