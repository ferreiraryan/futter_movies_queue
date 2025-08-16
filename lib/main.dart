import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart';
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart';
import 'firebase_options.dart'; // Arquivo gerado pelo FlutterFire
import 'features/auth/screens/login_screen.dart';
import 'package:flutter/rendering.dart';

void main() async {
  debugPaintSizeEnabled = false;
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fila de Filmes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Inter'),
      // O AuthGate decide qual tela mostrar
      home: const AuthGate(),
    );
  }
}

// O AuthGate é um "portão de autenticação" que verifica se o usuário
// está logado e mostra a tela correta.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o snapshot ainda não tem dados, mostra um loader
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        // Se tem dados (usuário logado), mostra a tela de filmes
        return const QueueLoaderScreen(screenType: ScreenType.upcoming);
      },
    );
  }
}
