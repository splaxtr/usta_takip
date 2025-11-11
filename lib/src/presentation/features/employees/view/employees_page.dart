import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/employee_repository.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<EmployeeRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Çalışanlar')),
      body: FutureBuilder(
        future: repository.getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final employees = snapshot.data!;
          if (employees.isEmpty) {
            return const Center(child: Text('Henüz çalışan eklenmedi'));
          }
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return ListTile(
                leading: CircleAvatar(child: Text(employee.name[0])),
                title: Text(employee.name),
                subtitle: Text('Günlük Ücret: ${employee.dailyWage} ₺'),
              );
            },
          );
        },
      ),
    );
  }
}
