import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create the AuthProvider instance
  final authProvider = AuthProvider();

  // Load user session
  await authProvider.loadUser();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Authentication App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: authProvider.isLoggedIn ? const HomePage() : LoginPage(),
      ),
    );
  }
}

