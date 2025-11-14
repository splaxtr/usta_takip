import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/services/backup_service.dart';
import '../../trash/view/trash_content.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        context.read<BackupService>(),
      )..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yedekleme'),
              Tab(text: 'Çöp Kutusu'),
              Tab(text: 'Hakkında'),
            ],
          ),
        ),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.statusMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.statusMessage!)),
              );
            }
          },
          builder: (context, state) {
            return TabBarView(
              children: [
                _BackupTab(state: state),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TrashContent(),
                ),
                const _AboutTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BackupTab extends StatelessWidget {
  const _BackupTab({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Yedek Oluştur'),
          subtitle: Text(
            state.lastBackup != null
                ? 'Son: ${state.lastBackup}'
                : 'Henüz yedek alınmadı',
          ),
          trailing: state.isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: state.isProcessing
              ? null
              : () => context.read<SettingsCubit>().backupNow(),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Son Yedeği Yükle'),
          onTap: state.isProcessing
              ? null
              : () => context.read<SettingsCubit>().restoreBackup(),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        Text(
          'Usta Takip',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Ustaların projelerini, çalışanlarını ve ödemelerini çevrimdışı takibi için tasarlandı. '
          'Veriler cihazınızda şifrelenmiş olarak saklanır. Premium aşamasında bulut senkronizasyonu gelecektir.',
        ),
      ],
    );
  }
}
