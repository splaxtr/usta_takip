import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap/app_dependencies.dart';
import 'domain/repositories/employee_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/ledger_repository.dart';
import 'domain/repositories/project_repository.dart';
import 'domain/repositories/wage_repository.dart';
import 'domain/services/auth_lock_service.dart';
import 'domain/services/backup_service.dart';
import 'domain/usecases/record_work_day.dart';
import 'presentation/core/lock/app_lock_state.dart';
import 'presentation/core/lock/lock_cubit.dart';
import 'presentation/core/lock/lock_screen.dart';
import 'presentation/features/archive/view/archive_page.dart';
import 'presentation/features/dashboard/cubit/dashboard_cubit.dart';
import 'presentation/features/dashboard/view/dashboard_page.dart';
import 'presentation/features/employees/view/employees_page.dart';
import 'presentation/features/projects/view/projects_page.dart';
import 'presentation/features/trash/view/trash_page.dart';

class UstaTakipApp extends StatefulWidget {
  const UstaTakipApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<UstaTakipApp> createState() => _UstaTakipAppState();
}

class _UstaTakipAppState extends State<UstaTakipApp> {
  int _selectedIndex = 0;

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
        RepositoryProvider<BackupService>.value(
          value: widget.dependencies.backupService,
        ),
        RepositoryProvider<AuthLockService>.value(
          value: widget.dependencies.authLockService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DashboardCubit(
              ledgerRepository: widget.dependencies.ledgerRepository,
              backupService: widget.dependencies.backupService,
              recordWorkDay: recordWorkDay,
            )..refresh(),
          ),
          BlocProvider(
            create: (_) =>
                LockCubit(widget.dependencies.authLockService)..initialize(),
          ),
        ],
        child: MaterialApp(
          title: 'Usta Takip',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
          ),
          home: BlocBuilder<LockCubit, AppLockState>(
            builder: (context, lockState) {
              if (lockState.isLocked) {
                return const LockScreen();
              }
              return Scaffold(
                body: IndexedStack(
                  index: _selectedIndex,
                  children: const [
                    DashboardPage(),
                    ProjectsPage(),
                    EmployeesPage(),
                    ArchivePage(),
                    TrashPage(),
                  ],
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.construction),
                      label: 'Projeler',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.groups_2_outlined),
                      label: 'Çalışanlar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.archive_outlined),
                      label: 'Arşiv',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.delete_outline),
                      label: 'Çöp',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
