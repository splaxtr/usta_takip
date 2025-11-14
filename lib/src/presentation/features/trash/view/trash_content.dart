import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/employee.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/project_repository.dart';
import '../cubit/trash_cubit.dart';
import '../cubit/trash_state.dart';

class TrashContent extends StatelessWidget {
  const TrashContent({super.key, this.embedded = true});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider(
      create: (_) => TrashCubit(
        context.read<ProjectRepository>(),
        context.read<EmployeeRepository>(),
      )..load(),
      child: const _TrashTabs(),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Çöp Kutusu')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: content,
      ),
    );
  }
}

class _TrashTabs extends StatelessWidget {
  const _TrashTabs();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Projeler'),
              Tab(text: 'Çalışanlar'),
            ],
          ),
          Expanded(
            child: BlocBuilder<TrashCubit, TrashState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  children: [
                    _TrashList<Project>(
                      items: state.projects,
                      subtitleBuilder: (project) =>
                          'Patron: ${project.patronId}',
                      onRestore: (id) =>
                          context.read<TrashCubit>().restoreProject(id),
                      onDeleteForever: (id) =>
                          context.read<TrashCubit>().deleteProjectForever(id),
                      emptyLabel: 'Silinmiş proje yok',
                    ),
                    _TrashList<Employee>(
                      items: state.employees,
                      subtitleBuilder: (employee) =>
                          'Proje: ${employee.projectId}',
                      onRestore: (id) =>
                          context.read<TrashCubit>().restoreEmployee(id),
                      onDeleteForever: (id) =>
                          context.read<TrashCubit>().deleteEmployeeForever(id),
                      emptyLabel: 'Silinmiş çalışan yok',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrashList<T> extends StatelessWidget {
  const _TrashList({
    required this.items,
    required this.subtitleBuilder,
    required this.onRestore,
    required this.onDeleteForever,
    required this.emptyLabel,
  });

  final List<T> items;
  final String Function(T) subtitleBuilder;
  final ValueChanged<String> onRestore;
  final ValueChanged<String> onDeleteForever;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyLabel));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = (item as dynamic).id as String;
        final title =
            item is Project ? item.name : item is Employee ? item.name : id;
        final subtitle = subtitleBuilder(item);
        return Card(
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_backup_restore),
                  onPressed: () => onRestore(id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => onDeleteForever(id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
