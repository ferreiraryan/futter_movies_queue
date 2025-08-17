import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/features/auth/screens/login_screen.dart';
// Precisaremos do QueueLoaderScreen aqui, use o caminho correto

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Mova o QueueLoaderScreen para uma pasta compartilhada ou ajuste o import
    // Por enquanto, vamos manter o código antigo para referência.
    // O ideal é que ele fique em `lib/shared/` ou `lib/features/movies/widgets`

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Se o usuário NÃO está logado, mostra a tela de Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Se o usuário ESTÁ logado, mostra o loader que buscará a fila
        // Lembre-se que já criamos este loader, você só precisa
        // colocá-lo no projeto novamente.
        // return const QueueLoaderScreen();

        // Por enquanto, vamos colocar um placeholder
        return const Scaffold(
          body: Center(
            child: Text("Logado com sucesso! Próximo passo: tela principal."),
          ),
        );
      },
    );
  }
}
