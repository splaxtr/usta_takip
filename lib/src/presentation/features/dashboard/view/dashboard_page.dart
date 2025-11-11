import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/record_work_day.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usta Takip Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardCubit>().refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordWorkDayDialog(context),
        label: const Text('Mesai Kaydet'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardCubit>().refresh(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DashboardCard(
                  title: 'Toplam Gelir',
                  value: '${state.totalIncome.toStringAsFixed(0)} ₺',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _DashboardCard(
                  title: 'Ödenmiş Giderler',
                  value: '${state.paidExpenses.toStringAsFixed(0)} ₺',
                  icon: Icons.outbox_rounded,
                ),
                _DashboardCard(
                  title: 'Bekleyen Yevmiyeler',
                  value: '${state.pendingWages.toStringAsFixed(0)} ₺',
                  icon: Icons.timer_outlined,
                  valueColor: Colors.orange.shade700,
                ),
                _DashboardCard(
                  title: 'Aktif Proje',
                  value: state.activeProjects.toString(),
                  icon: Icons.home_repair_service_outlined,
                ),
                _DashboardCard(
                  title: 'Son Yedekleme',
                  value: state.lastBackup != null
                      ? state.lastBackup!.toLocal().toString()
                      : 'Henüz yapılmadı',
                  icon: Icons.backup_outlined,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRecordWorkDayDialog(BuildContext context) async {
    final employeeController = TextEditingController();
    final projectController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesai Kaydet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: projectController,
              decoration: const InputDecoration(labelText: 'Proje ID'),
            ),
            TextField(
              controller: employeeController,
              decoration: const InputDecoration(labelText: 'Çalışan ID'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Tutar'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final employeeId = employeeController.text.trim();
              final projectId = projectController.text.trim();
              if (employeeId.isEmpty || projectId.isEmpty || amount <= 0) {
                return;
              }
              await context.read<DashboardCubit>().recordWorkDay(
                    RecordWorkDayParams(
                      employeeId: employeeId,
                      projectId: projectId,
                      date: DateTime.now(),
                      amount: amount,
                    ),
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: valueColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
