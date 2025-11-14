import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/employee.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/patron_repository.dart';
import '../../../../domain/repositories/project_repository.dart';
import '../../../../presentation/features/settings/view/settings_page.dart';
import '../../../dashboard/cubit/dashboard_cubit.dart';
import '../../../dashboard/cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<DashboardCubit>().refresh(),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(
                      onAddEmployee: () => _quickAddEmployee(context),
                      onAddProject: () => _quickAddProject(context),
                      onOpenSettings: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _MetricCard(
                          icon: Icons.payments_outlined,
                          label: 'Toplam Gelir',
                          value:
                              '${state.totalIncome.toStringAsFixed(0)} ₺',
                          color: const Color(0xFF2563EB),
                        ),
                        _MetricCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Toplam Gider',
                          value:
                              '${state.totalExpenses.toStringAsFixed(0)} ₺',
                          color: const Color(0xFF60A5FA),
                        ),
                        _MetricCard(
                          icon: Icons.timer_outlined,
                          label: 'Bekleyen Yevmiye',
                          value:
                              '${state.pendingWages.toStringAsFixed(0)} ₺',
                          color: Colors.orangeAccent,
                        ),
                        _MetricCard(
                          icon: Icons.assignment_outlined,
                          label: 'Aktif Proje',
                          value: state.activeProjects.toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _TrendCard(weeklyTrend: state.weeklyTrend),
                    const SizedBox(height: 16),
                    _ReminderCard(reminders: state.reminders),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _quickAddEmployee(BuildContext context) async {
    final employeeRepo = context.read<EmployeeRepository>();
    final projectRepo = context.read<ProjectRepository>();
    final projects = await projectRepo.getAll();
    final nameController = TextEditingController();
    final wageController = TextEditingController();
    String? selectedProjectId =
        projects.isNotEmpty ? projects.first.id : null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı Çalışan Ekle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Zorunlu'
                        : null,
              ),
              TextFormField(
                controller: wageController,
                decoration:
                    const InputDecoration(labelText: 'Günlük Ücret'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    (double.tryParse(value ?? '') ?? 0) <= 0
                        ? 'Geçerli tutar girin'
                        : null,
              ),
              if (projects.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedProjectId,
                  decoration:
                      const InputDecoration(labelText: 'Proje'),
                  items: projects
                      .map(
                        (project) => DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedProjectId = value,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final employee = Employee(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                dailyWage: double.parse(wageController.text.trim()),
                phone: '',
                projectId: selectedProjectId ?? '',
              );
              await employeeRepo.add(employee);
              if (context.mounted) {
                Navigator.pop(context);
                context.read<DashboardCubit>().refresh();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _quickAddProject(BuildContext context) async {
    final projectRepo = context.read<ProjectRepository>();
    final patronRepo = context.read<PatronRepository>();
    final patrons = await patronRepo.getAll();
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String? selectedPatronId =
        patrons.isNotEmpty ? patrons.first.id : null;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı Proje Ekle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Proje Adı'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Zorunlu'
                        : null,
              ),
              TextFormField(
                controller: budgetController,
                decoration:
                    const InputDecoration(labelText: 'Toplam Bütçe'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    (double.tryParse(value ?? '') ?? 0) <= 0
                        ? 'Geçerli bütçe'
                        : null,
              ),
              if (patrons.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedPatronId,
                  decoration:
                      const InputDecoration(labelText: 'Patron'),
                  items: patrons
                      .map(
                        (patron) => DropdownMenuItem(
                          value: patron.id,
                          child: Text(patron.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedPatronId = value,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final project = Project(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                patronId: selectedPatronId ?? '',
                totalBudget: double.parse(budgetController.text.trim()),
                defaultDailyWage: 0,
                startDate: DateTime.now(),
              );
              await projectRepo.add(project);
              if (context.mounted) {
                Navigator.pop(context);
                context.read<DashboardCubit>().refresh();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onAddEmployee,
    required this.onAddProject,
    required this.onOpenSettings,
  });

  final VoidCallback onAddEmployee;
  final VoidCallback onAddProject;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usta Takip',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Projelerini tek yerden yönet',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
            IconButton(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _QuickActionButton(
              icon: Icons.person_add_alt,
              label: 'Çalışan',
              onTap: onAddEmployee,
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.add_business,
              label: 'Proje',
              onTap: onAddProject,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF2563EB)),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.weeklyTrend});

  final List<double> weeklyTrend;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bu Hafta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Icon(Icons.show_chart, color: Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: weeklyTrend.isEmpty
                  ? const Center(child: Text('Grafik için veri bekleniyor'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(labels[index],
                                    style: const TextStyle(fontSize: 11));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: const Color(0xFF2563EB),
                            dotData: const FlDotData(show: false),
                            barWidth: 4,
                            spots: weeklyTrend
                                .asMap()
                                .entries
                                .map(
                                  (entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminders});

  final List<String> reminders;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
              'Hatırlatmalar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...reminders.map(
              (reminder) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active,
                        size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reminder)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
