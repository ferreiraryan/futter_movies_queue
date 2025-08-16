import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart'; // <<< Importe seu AuthService
import 'package:movie_queue/features/auth/screens/login_screen.dart'; // <<< Importe sua tela de Login
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart';

class QueueLoaderScreen extends StatelessWidget {
  final ScreenType screenType;

  const QueueLoaderScreen({super.key, required this.screenType});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    // <<< MUDANÇA: Instancia o AuthService para podermos deslogar
    final authService = AuthService();

    return StreamBuilder(
      stream: firestoreService.getUserDocStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // <<< MUDANÇA: Lógica de logout implementada
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          // Agenda o logout e a navegação para depois do build, evitando erros.
          Future.microtask(() {
            // 1. Desloga o usuário
            authService.signOut();

            // 2. Navega para a tela de login, removendo todas as telas anteriores da pilha.
            // Isso garante que o usuário não possa voltar para uma tela "quebrada".
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ), // Verifique se o nome da sua tela de login está correto
              (Route<dynamic> route) => false,
            );
          });

          // Enquanto a tarefa acima é executada, mostramos um loader.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String? queueId = userData['activeQueueId'];

        if (queueId == null) {
          return const Scaffold(
            body: Center(child: Text("Erro: Nenhuma fila ativa encontrada.")),
          );
        }

        return MovieListScreen(screenType: screenType, queueId: queueId);
      },
    );
  }
}
