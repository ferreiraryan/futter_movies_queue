import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/social/view_models/social_view_model.dart';
import 'package:movie_queue/features/social/widgets/hall_of_fame_card.dart';
import 'package:movie_queue/features/social/widgets/member_card.dart';
import 'package:movie_queue/features/social/widgets/pending_invite_card.dart';
import 'package:movie_queue/features/social/widgets/scoreboard_card.dart';
import 'package:movie_queue/features/social/widgets/stats_card.dart';
import 'package:movie_queue/shared/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

// O "Provider" / "Wrapper" que cria o ViewModel
class SocialScreenProvider extends StatelessWidget {
  final String queueId;
  const SocialScreenProvider({super.key, required this.queueId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocialViewModel()..listenToQueue(queueId),
      child: const SocialScreen(),
    );
  }
}

// A tela que exibe os dados
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Social')),
          drawer: AppDrawer(queueId: viewModel.queueId),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      // Cria uma instância temporária do serviço para buscar os convites
                      stream: FirestoreService().getPendingInvitesForUser(),
                      builder: (context, inviteSnapshot) {
                        if (!inviteSnapshot.hasData ||
                            inviteSnapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: inviteSnapshot.data!.docs
                              .map(
                                (inviteDoc) =>
                                    PendingInviteCard(invite: inviteDoc),
                              )
                              .toList(),
                        );
                      },
                    ),

                    Expanded(
                      child: (viewModel.memberIds.length <= 1)
                          ? _buildLonelyState(context)
                          : _buildSocialContent(viewModel), // Conteúdo social
                    ),
                  ],
                ),
          floatingActionButton: (viewModel.memberIds.length > 1)
              ? FloatingActionButton(
                  onPressed: () =>
                      _showInviteDialog(context, viewModel.queueId),
                  child: const Icon(Icons.person_add),
                )
              : null,
        );
      },
    );
  }

  // Helper para o conteúdo social principal
  Widget _buildSocialContent(SocialViewModel viewModel) {
    return ListView(
      children: [
        if (viewModel.topRatedResult != null)
          HallOfFameCard(
            movie: viewModel.topRatedResult!['movie'],
            averageRating: viewModel.topRatedResult!['averageRating'],
          ),

        StatsCard(
          movieCount: viewModel.watchedMovieCount,
          totalMinutes: viewModel.totalMinutes,
        ),

        ScoreboardCard(stats: viewModel.scoreboardStats),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Membros da Fila:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...viewModel.memberIds.map((id) {
          final name = viewModel.membersData[id]?['displayName'] ?? '...';
          final email = viewModel.membersData[id]?['email'] ?? '...';
          return MemberCard(name: name, email: email);
        }),
      ],
    );
  }

  // Helper para a tela de "sozinho"
  Widget _buildLonelyState(BuildContext context) {
    final viewModel = Provider.of<SocialViewModel>(context, listen: false);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_add, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Você ainda está sozinho por aqui!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Convide um amigo para compartilhar esta fila de filmes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showInviteDialog(context, viewModel.queueId),
              icon: const Icon(Icons.person_add),
              label: const Text('Convidar Amigo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String queueId) {
    final emailController = TextEditingController();
    final firestoreService = FirestoreService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar para a Fila'),
        content: TextField(
          controller: emailController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Email do amigo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Agora a chamada funciona
              await firestoreService.sendInvite(
                inviteeEmail: emailController.text,
                queueId: queueId,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Enviar Convite'),
          ),
        ],
      ),
    );
  }
}
