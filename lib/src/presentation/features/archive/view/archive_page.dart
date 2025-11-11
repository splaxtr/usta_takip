import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/employee.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/project_repository.dart';
import '../cubit/archive_cubit.dart';
import '../cubit/archive_state.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArchiveCubit(
        context.read<ProjectRepository>(),
        context.read<EmployeeRepository>(),
      )..load(),
      child: const _ArchiveView(),
    );
  }
}

class _ArchiveView extends StatelessWidget {
  const _ArchiveView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Arşiv'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Projeler'),
              Tab(text: 'Çalışanlar'),
            ],
          ),
        ),
        body: BlocBuilder<ArchiveCubit, ArchiveState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _ArchiveList(
                  items: state.projects,
                  onRestore: (id) =>
                      context.read<ArchiveCubit>().restoreProject(id),
                  emptyLabel: 'Arşivde proje yok',
                ),
                _ArchiveList(
                  items: state.employees,
                  onRestore: (id) =>
                      context.read<ArchiveCubit>().restoreEmployee(id),
                  emptyLabel: 'Arşivde çalışan yok',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  const _ArchiveList({
    required this.items,
    required this.onRestore,
    required this.emptyLabel,
  });

  final List<dynamic> items;
  final ValueChanged<String> onRestore;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyLabel));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        String title;
        String? subtitle;
        if (item is Project) {
          title = item.name;
          subtitle = 'Patron: ${item.patronId}';
        } else if (item is Employee) {
          title = item.name;
          subtitle = 'Proje: ${item.projectId}';
        } else {
          title = item.toString();
        }
        final id = (item as dynamic).id as String;
        final subtitleWidget =
            (subtitle?.isNotEmpty ?? false) ? Text(subtitle!) : null;
        return ListTile(
          title: Text(title),
          subtitle: subtitleWidget,
          trailing: TextButton(
            onPressed: () => onRestore(id),
            child: const Text('Geri Yükle'),
          ),
        );
      },
    );
  }
}
