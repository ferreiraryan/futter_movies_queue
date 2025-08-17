// lib/features/social/screens/social_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
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
                    // Chama a função que criamos no nosso serviço
                    await _firestoreService.sendInvite(
                      inviteeEmail: email,
                      queueId: widget.queueId,
                    );
                    Navigator.of(context).pop(); // Fecha o dialog
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
      body: StreamBuilder<DocumentSnapshot>(
        // Ouve os dados da fila atual em tempo real
        stream: _firestoreService.getQueueStream(widget.queueId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final queueData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> members = queueData['members'] ?? [];

          // Se o usuário está sozinho na fila
          if (members.length <= 1) {
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

          // Se há mais gente na fila
          return Column(
            children: [
              // TODO: Mostrar o card de convite pendente (próximo passo)

              // TODO: Mostrar a lista de membros e comparação de notas
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Membros da Fila:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        'Membro ${index + 1} (ID: ${members[index]})',
                      ), // Placeholder
                    );
                  },
                ),
              ),
            ],
          );
        },
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
