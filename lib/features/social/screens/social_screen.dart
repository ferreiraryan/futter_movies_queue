import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/social/view_models/social_view_model.dart';
import 'package:movie_queue/features/social/widgets/PersonalityInsightsCard.dart';
import 'package:movie_queue/features/social/widgets/goal_card.dart';
import 'package:movie_queue/features/social/widgets/hall_of_fame_card.dart';
import 'package:movie_queue/features/social/widgets/member_card.dart';
import 'package:movie_queue/features/social/widgets/pending_invite_card.dart';
import 'package:movie_queue/features/social/widgets/scoreboard_card.dart';
import 'package:movie_queue/features/social/widgets/stats_card.dart';
import 'package:movie_queue/shared/widgets/app_drawer.dart';
import 'package:provider/provider.dart';


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
                          : _buildSocialContent(context, viewModel),
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

  
  Widget _buildSocialContent(BuildContext context, SocialViewModel viewModel) {
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

        GoalCard(
          watchedCount: viewModel.watchedMovieCount,
          goal: viewModel.currentGoal,
          endDate: viewModel.goalEndDate,
          onEdit: () => _showEditGoalDialog(
            context,
            viewModel.queueId,
            viewModel.currentGoal,
            viewModel.goalEndDate,
          ),
        ),

        ScoreboardCard(stats: viewModel.scoreboardStats),

        if (viewModel.enthusiastId != null && viewModel.criticId != null)
          PersonalityInsightsCard(
            enthusiastName:
                viewModel.membersData[viewModel.enthusiastId]?['displayName'] ??
                '...',
            enthusiastAvg: viewModel.enthusiastAvg,
            criticName:
                viewModel.membersData[viewModel.criticId]?['displayName'] ??
                '...',
            criticAvg: viewModel.criticAvg,
          ),

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
        }).toList(),
      ],
    );
  }

  
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

  
  void _showEditGoalDialog(
    BuildContext context,
    String queueId,
    int currentGoal,
    DateTime? currentDate,
  ) {
    final controller = TextEditingController(text: currentGoal.toString());
    final firestoreService = FirestoreService();

    DateTime? selectedDate = currentDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Definir Nova Meta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Quantos filmes?',
                      hintText: 'Ex: 50',
                      icon: Icon(Icons.movie),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      selectedDate == null
                          ? 'Definir Data Limite (Opcional)'
                          : 'Prazo: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                    ),
                    leading: const Icon(Icons.calendar_today),
                    trailing: selectedDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setStateDialog(() => selectedDate = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            selectedDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newGoal = int.tryParse(controller.text);
                    if (newGoal != null && newGoal > 0) {
                      firestoreService.updateQueueGoal(
                        queueId,
                        newGoal,
                        selectedDate,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
