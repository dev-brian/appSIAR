import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:siar/screens/add_product_screen.dart';
import 'package:siar/screens/home_screen.dart';
import 'package:siar/theme/app_theme.dart';
import 'firebase_options.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siar App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MainScreen(),
        '/add-product': (context) => const AddProductScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(child: Text('No hay estadísticas disponibles')),
    ),
    const AddProductScreen(),
    Scaffold(
      appBar: AppBar(title: Text('Notificaciones')),
      body: const Center(child: Text('No hay notificaciones')),
    ),
    Scaffold(
      appBar: AppBar(title: Text('Cuenta')),
      body: const Center(child: Text('Información de tu cuenta')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Navegar a AddProductScreen
            Navigator.pushNamed(context, '/add-product');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
