import 'package:crud/Pages/home_page.dart';
import 'package:crud/Pages/tela_login.dart';
import 'package:crud/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      title: 'Meu App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const AuthGate(),
    );
  }
}

/// Monitora o estado de autenticação e decide qual tela mostrar:
/// - Se estiver logado (User != null): HomePage
/// - Se não estiver logado: LoginScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto aguarda o estado...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver logado, mostra a home
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Caso contrário, mostra a tela de login
        return const LoginScreen();
      },
    );
  }
}
