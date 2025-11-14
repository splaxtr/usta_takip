import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap/app_dependencies.dart';
import 'domain/repositories/employee_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/ledger_repository.dart';
import 'domain/repositories/patron_repository.dart';
import 'domain/repositories/project_repository.dart';
import 'domain/repositories/wage_repository.dart';
import 'domain/services/backup_service.dart';
import 'domain/usecases/record_work_day.dart';
import 'presentation/features/archive/view/archive_page.dart';
import 'presentation/features/dashboard/cubit/dashboard_cubit.dart';
import 'presentation/features/dashboard/view/dashboard_page.dart';
import 'presentation/features/employees/view/employees_page.dart';
import 'presentation/features/patrons/view/patrons_page.dart';
import 'presentation/features/projects/view/projects_page.dart';

class UstaTakipApp extends StatefulWidget {
  const UstaTakipApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<UstaTakipApp> createState() => _UstaTakipAppState();
}

class _UstaTakipAppState extends State<UstaTakipApp> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final recordWorkDay = RecordWorkDay(
      widget.dependencies.wageRepository,
      widget.dependencies.expenseRepository,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProjectRepository>.value(
          value: widget.dependencies.projectRepository,
        ),
        RepositoryProvider<EmployeeRepository>.value(
          value: widget.dependencies.employeeRepository,
        ),
        RepositoryProvider<WageRepository>.value(
          value: widget.dependencies.wageRepository,
        ),
        RepositoryProvider<ExpenseRepository>.value(
          value: widget.dependencies.expenseRepository,
        ),
        RepositoryProvider<LedgerRepository>.value(
          value: widget.dependencies.ledgerRepository,
        ),
        RepositoryProvider<PatronRepository>.value(
          value: widget.dependencies.patronRepository,
        ),
        RepositoryProvider<BackupService>.value(
          value: widget.dependencies.backupService,
        ),
      ],
      child: BlocProvider(
        create: (_) => DashboardCubit(
          ledgerRepository: widget.dependencies.ledgerRepository,
          backupService: widget.dependencies.backupService,
          recordWorkDay: recordWorkDay,
        )..refresh(),
        child: MaterialApp(
          title: 'Usta Takip',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9FAFB),
              foregroundColor: Color(0xFF0F172A),
              elevation: 0,
            ),
          ),
          home: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: const [
                EmployeesPage(),
                PatronsPage(),
                DashboardPage(),
                ProjectsPage(),
                ArchivePage(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              height: 72,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFDBEAFE),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: 'Çalışanlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.handshake_outlined),
                  label: 'Patronlar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.apartment_outlined),
                  label: 'Projeler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Arşiv',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
