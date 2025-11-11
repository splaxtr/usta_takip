import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/services/auth_lock_service.dart';
import '../../../../domain/services/backup_service.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        context.read<AuthLockService>(),
        context.read<BackupService>(),
      )..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.statusMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.statusMessage!)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('PIN / Biyometrik Kilit'),
                value: state.lockEnabled,
                onChanged: state.isProcessing
                    ? null
                    : (value) async {
                        if (value) {
                          final pin = await _askForPin(context);
                          if (pin != null && pin.length >= 4) {
                            await context.read<SettingsCubit>().enableLock(pin);
                          }
                        } else {
                          await context.read<SettingsCubit>().disableLock();
                        }
                      },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Hemen Yedekle'),
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
                title: const Text('Son Yedeği Geri Yükle'),
                onTap: state.isProcessing
                    ? null
                    : () => context.read<SettingsCubit>().restoreBackup(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _askForPin(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN oluştur'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'En az 4 haneli PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
