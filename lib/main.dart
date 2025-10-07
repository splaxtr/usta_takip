import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'shared/layouts/main_layout.dart';
import 'shared/widgets/bottom_nav_bar.dart';

/// Ana uygulama giriş noktası
///
/// Uygulamayı başlatır ve MaterialApp'i yapılandırır
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Yatay mod kilidi (isteğe bağlı)
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(const MyApp());
}

/// Ana uygulama widget'ı
///
/// Material Design temalarını ve navigation yapısını tanımlar
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İnşaat Yönetim Sistemi',
      debugShowCheckedModeBanner: false,

      // Tema ayarları
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.light, // ThemeMode.system için cihaz ayarını kullanır

      // Ana ekran
      home: MainLayoutWithRealScreens(
        useStack: true, // State korumak için IndexedStack kullan
        useFloating: false, // Normal bottom nav kullan
        screens: const [
          DashboardScreen(userName: 'Ahmet Yılmaz'),
          ProjectsScreen(),
          EmployeesScreen(),
          FinancialsScreen(),
          ProfileScreen(),
        ],
        navItems: const [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Ana Sayfa',
            screen: DashboardScreen(userName: 'Ahmet Yılmaz'),
          ),
          NavItem(
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'Projeler',
            screen: ProjectsScreen(),
          ),
          NavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Çalışanlar',
            screen: EmployeesScreen(),
          ),
          NavItem(
            icon: Icons.payments_outlined,
            activeIcon: Icons.payments,
            label: 'Finans',
            screen: FinancialsScreen(),
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            screen: ProfileScreen(),
          ),
        ],
      ),

      // Route'lar (deep linking için)
      routes: {
        '/dashboard': (context) =>
            const DashboardScreen(userName: 'Ahmet Yılmaz'),
        '/projects': (context) => const ProjectsScreen(),
        '/employees': (context) => const EmployeesScreen(),
        '/financials': (context) => const FinancialsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

/// Uygulama tema ayarları
class AppTheme {
  // Renk paleti
  static const Color primaryColor = Color(0xFF2196F3); // Mavi
  static const Color secondaryColor = Color(0xFF03A9F4); // Açık Mavi
  static const Color accentColor = Color(0xFFFF9800); // Turuncu
  static const Color errorColor = Color(0xFFE53935); // Kırmızı
  static const Color successColor = Color(0xFF4CAF50); // Yeşil

  /// Light tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Renk şeması
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),

      // Scaffold arka plan rengi
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),

      // AppBar teması
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card teması
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),

      // Button temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input decoration teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Text teması
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),

      // Icon teması
      iconTheme: const IconThemeData(
        color: Colors.black87,
        size: 24,
      ),

      // Divider teması
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button teması
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Dark tema
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Renk şeması
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),

      // Scaffold arka plan rengi
      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar teması
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card teması
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
      ),

      // Button temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input decoration teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Placeholder ekranlar (gerçek ekranlar oluşturulana kadar)
///
/// TODO: Bu ekranları gerçek ekranlarla değiştirin

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeler'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Projeler Ekranı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz oluşturulmadı',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yeni proje ekleniyor...')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışanlar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Çalışanlar Ekranı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz oluşturulmadı',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yeni çalışan ekleniyor...')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FinancialsScreen extends StatelessWidget {
  const FinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finans'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Finans Ekranı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz oluşturulmadı',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Profil Ekranı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz oluşturulmadı',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternatif main.dart örnekleri:
///
/// ```dart
/// // 1. Basit başlangıç (placeholder ekranlarla)
/// void main() {
///   runApp(MaterialApp(
///     home: MainLayout(),
///   ));
/// }
///
/// // 2. Floating navigation ile
/// void main() {
///   runApp(MaterialApp(
///     home: MainLayoutWithFloating(),
///   ));
/// }
///
/// // 3. Minimal tasarım
/// void main() {
///   runApp(MaterialApp(
///     home: MainLayoutMinimal(
///       navItems: [...],
///     ),
///   ));
/// }
///
/// // 4. Tema değiştirme ile (StatefulWidget)
/// class MyApp extends StatefulWidget {
///   @override
///   State<MyApp> createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   ThemeMode _themeMode = ThemeMode.light;
///
///   void _toggleTheme() {
///     setState(() {
///       _themeMode = _themeMode == ThemeMode.light 
///         ? ThemeMode.dark 
///         : ThemeMode.light;
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       theme: AppTheme.lightTheme,
///       darkTheme: AppTheme.darkTheme,
///       themeMode: _themeMode,
///       home: DashboardScreen(userName: 'Ahmet'),
///     );
///   }
/// }
///
/// // 5. Splash screen ile
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Future.delayed(Duration(seconds: 2)); // Splash delay
///   runApp(MyApp());
/// }
/// ```
///
/// Önemli Notlar:
/// - TODO: Placeholder ekranları gerçek ekranlarla değiştirin
/// - Kullanıcı adını dinamik hale getirin (SharedPreferences, API vb.)
/// - State management ekleyin (Provider, Riverpod, Bloc vb.)
/// - Authentication ekranları ekleyin (Login, Register)
/// - Route navigation'ı geliştirin (named routes, go_router)
/// - Error handling ve loading states ekleyin
/// - Offline mode desteği ekleyin
/// - Push notification entegrasyonu yapın