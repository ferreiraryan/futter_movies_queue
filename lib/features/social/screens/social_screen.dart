import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/social/widgets/hall_of_fame_card.dart';
import 'package:movie_queue/features/social/widgets/member_card.dart';
import 'package:movie_queue/features/social/widgets/pending_invite_card.dart';
import 'package:movie_queue/shared/widgets/app_drawer.dart';

class SocialScreen extends StatefulWidget {
  final String queueId;
  const SocialScreen({super.key, required this.queueId});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _emailController = TextEditingController();

  Map<String, dynamic>? _findTopRatedMovie(List<dynamic> watchedMoviesRaw) {
    if (watchedMoviesRaw.isEmpty) return null;

    Movie? topMovie;
    double maxAverage = 0.0;

    // 1. Itera por cada filme na lista de assistidos
    for (var movieData in watchedMoviesRaw) {
      final movie = Movie.fromMap(movieData);
      final ratings = movie.ratings;

      // 2. Se o filme tem notas, calcula a média
      if (ratings != null && ratings.isNotEmpty) {
        double currentSum = ratings.values.reduce((a, b) => a + b);
        double currentAverage = currentSum / ratings.length;

        // 3. Compara com a maior média encontrada até agora
        if (currentAverage > maxAverage) {
          maxAverage = currentAverage;
          topMovie = movie;
        }
      }
    }

    if (topMovie == null) return null;

    return {'movie': topMovie, 'averageRating': maxAverage};
  }

  // Função para mostrar o popup de convite
  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Convidar para a Fila'),
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email do amigo',
              hintText: 'amigo@exemplo.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                if (email.isNotEmpty) {
                  try {
                    await _firestoreService.sendInvite(
                      inviteeEmail: email,
                      queueId: widget.queueId,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Convite enviado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _emailController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao enviar convite: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar Convite'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      drawer: AppDrawer(queueId: widget.queueId),
      body: Column(
        children: [
          // WIDGET 1: STREAM DOS CONVITES (SEMPRE VERIFICA, INDEPENDENTE DA FILA)
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getPendingInvitesForUser(),
            builder: (context, inviteSnapshot) {
              if (!inviteSnapshot.hasData ||
                  inviteSnapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink(); // Sem convites, não mostra nada
              }
              // Com convites, mostra a lista deles no topo
              return Column(
                children: inviteSnapshot.data!.docs
                    .map((inviteDoc) => PendingInviteCard(invite: inviteDoc))
                    .toList(),
              );
            },
          ),

          // WIDGET 2: STREAM DO CONTEÚDO DA FILA (OCUPA O RESTO DA TELA)
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getQueueStream(widget.queueId),
              builder: (context, queueSnapshot) {
                if (!queueSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final queueData =
                    queueSnapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> members = queueData['members'] ?? [];

                final List<dynamic> watchedMoviesRaw =
                    queueData['watched_movies'] ?? [];
                final topRatedResult = _findTopRatedMovie(watchedMoviesRaw);

                // CASO 1: Usuário está sozinho na fila
                if (members.length <= 1) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.group_add,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Você ainda está sozinho por aqui!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Convide um amigo para compartilhar esta fila de filmes e comparar suas notas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _showInviteDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Convidar Amigo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // CASO 2: Há mais gente na fila
                return ListView(
                  children: [
                    if (topRatedResult != null)
                      HallOfFameCard(
                        movie: topRatedResult['movie'],
                        averageRating: topRatedResult['averageRating'],
                      ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Membros da Fila:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Desativa o scroll desta lista
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return MemberCard(memberId: members[index]);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Botão flutuante só aparece se já houver amigos na fila
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getQueueStream(widget.queueId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final members =
              (snapshot.data!.data() as Map<String, dynamic>)['members'] ?? [];
          return members.length > 1
              ? FloatingActionButton(
                  onPressed: _showInviteDialog,
                  child: const Icon(Icons.person_add),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
