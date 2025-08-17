import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/features/auth/screens/login_screen.dart';
// Certifique-se de importar o QueueLoaderScreen
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // AGORA SIM: Se o usuário está logado, mostramos o loader.
        // Por padrão, ele tentará carregar a tela de "upcoming".
        return const QueueLoaderScreen();
      },
    );
  }
}
