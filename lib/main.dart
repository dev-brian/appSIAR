import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// Screens
import 'package:siar/screens/add_product_screen.dart';
import 'package:siar/screens/home_screen.dart';
import 'package:siar/screens/signin_screen.dart';
import 'package:siar/screens/profile_screen.dart';
// Theme
import 'package:siar/theme/app_theme.dart';
// Widgets
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
      home: const AuthWrapper(), // Cambiamos el punto de entrada a AuthWrapper
      routes: {
        '/home': (context) => const MainScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/signin': (context) => SignInScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si el estado de autenticación está cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si el usuario no está autenticado, mostrar SignInScreen
        if (!snapshot.hasData) {
          return SignInScreen();
        }

        // Si el usuario está autenticado, mostrar MainScreen
        return const MainScreen();
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
      appBar: AppBar(title: const Text('Notificaciones')),
      body: const Center(child: Text('No hay notificaciones')),
    ),
    const ProfileScreen(),
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
