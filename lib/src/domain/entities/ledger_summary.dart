class LedgerSummary {
  const LedgerSummary({
    required this.totalIncome,
    required this.paidExpenses,
    required this.pendingWages,
    required this.outstandingPatronPayments,
    required this.activeProjects,
    this.lastBackup,
  });

  final double totalIncome;
  final double paidExpenses;
  final double pendingWages;
  final double outstandingPatronPayments;
  final int activeProjects;
  final DateTime? lastBackup;
}
