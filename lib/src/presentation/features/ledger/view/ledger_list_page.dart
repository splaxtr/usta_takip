import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/ledger_repository.dart';
import '../../../../data/models/expense.dart';
import '../../../../data/models/project.dart';
import '../../../../data/models/wage_entry.dart';

enum LedgerListType { pendingWages, paidExpenses, outstanding }

class LedgerListPage extends StatelessWidget {
  const LedgerListPage({super.key, required this.listType});

  final LedgerListType listType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<List<dynamic>>(
        future: _loadData(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(child: Text('Kayıt bulunamadı: $_title'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is WageEntry) {
                return ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('Çalışan: ${item.employeeId}'),
                  subtitle: Text('Tutar: ${item.amount} ₺'),
                  trailing: Text(item.status),
                );
              } else if (item is Expense) {
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(item.description),
                  subtitle: Text('Proje: ${item.projectId}'),
                  trailing: Text('${item.amount.toStringAsFixed(0)} ₺'),
                );
              } else if (item is Project) {
                return ListTile(
                  leading: const Icon(Icons.construction),
                  title: Text(item.name),
                  subtitle:
                      Text('Bütçe: ${item.totalBudget.toStringAsFixed(0)} ₺'),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _loadData(BuildContext context) {
    final repository = context.read<LedgerRepository>();
    switch (listType) {
      case LedgerListType.pendingWages:
        return repository.pendingWages();
      case LedgerListType.paidExpenses:
        return repository.paidExpenses();
      case LedgerListType.outstanding:
        return repository.outstandingPatronPayments();
    }
  }

  String get _title {
    switch (listType) {
      case LedgerListType.pendingWages:
        return 'Bekleyen Yevmiyeler';
      case LedgerListType.paidExpenses:
        return 'Ödenmiş Giderler';
      case LedgerListType.outstanding:
        return 'Patron Alacakları';
    }
  }
}
