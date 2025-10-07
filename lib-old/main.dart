import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/first_login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  await Hive.initFlutter();

  // Hive kutularını aç
  await Hive.openBox('user');
  await Hive.openBox('projeler');
  await Hive.openBox('calisanlar');
  await Hive.openBox('patronlar');
  await Hive.openBox('mesailer');
  await Hive.openBox('gelirgider');

  runApp(const UstaTakipApp());
}

class UstaTakipApp extends StatelessWidget {
  const UstaTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kullanıcı daha önce giriş yaptı mı kontrol et
    final userBox = Hive.box('user');
    final hasUser = userBox.get('fullName') != null;

    return MaterialApp(
      title: 'Usta Takip',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: hasUser ? DashboardScreen() : FirstLoginScreen(),
    );
  }
}
