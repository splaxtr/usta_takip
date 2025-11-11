import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/project_repository.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProjectRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Projeler')),
      body: FutureBuilder(
        future: repository.getAll(includeArchived: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return const Center(child: Text('Henüz proje yok'));
          }
          return ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.name),
                subtitle: Text(
                  'Bütçe: ${project.totalBudget.toStringAsFixed(0)} ₺ | Günlük: ${project.defaultDailyWage}',
                ),
                trailing: Icon(
                  project.isArchived ? Icons.archive : Icons.check_circle,
                  color: project.isArchived ? Colors.orange : Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
