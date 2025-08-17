import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart';

class QueueLoaderScreen extends StatelessWidget {
  final ScreenType destinationScreenType;

  const QueueLoaderScreen({
    super.key,
    this.destinationScreenType = ScreenType.upcoming,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<DocumentSnapshot>(
      stream: firestoreService.getUserDocStream(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // <<< MUDANÇA AQUI >>>
        // Se o usuário está autenticado, mas não tem dados no Firestore,
        // chamamos nosso novo widget de logout.
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const _SignOutAndRedirect();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String? queueId = userData['activeQueueId'];

        if (queueId == null) {
          // Se o documento existe mas não tem a queueId, também deslogamos.
          return const _SignOutAndRedirect(
            reason: "Erro: Fila ativa não encontrada.",
          );
        }

        return MovieListScreen(
          queueId: queueId,
          screenType: destinationScreenType,
        );
      },
    );
  }
}

/// Widget auxiliar que desloga o usuário e mostra uma mensagem.
/// Ele é "privado" (começa com _) pois só será usado neste arquivo.
class _SignOutAndRedirect extends StatefulWidget {
  final String reason;
  const _SignOutAndRedirect({
    this.reason = "Dados do usuário não encontrados.",
  });

  @override
  State<_SignOutAndRedirect> createState() => _SignOutAndRedirectState();
}

class _SignOutAndRedirectState extends State<_SignOutAndRedirect> {
  @override
  void initState() {
    super.initState();
    // Agendamos o logout para ocorrer logo após a construção da tela,
    // para evitar erros de "setState during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService().signOut();
      // Não precisamos navegar manualmente, o AuthGate fará isso por nós.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.reason,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text("Redirecionando para a tela de login..."),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
