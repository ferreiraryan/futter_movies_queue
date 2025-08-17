// lib/features/social/widgets/member_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';

class MemberCard extends StatelessWidget {
  final String memberId;
  const MemberCard({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    // FutureBuilder é perfeito para buscar dados que não mudam em tempo real.
    return FutureBuilder<DocumentSnapshot>(
      // 1. A "Future": o que estamos esperando? A busca do documento do usuário.
      future: firestoreService.getUserDocById(memberId),

      // 2. O "builder": o que mostrar em cada estado (carregando, erro, sucesso).
      builder: (context, snapshot) {
        // Enquanto está carregando, mostramos um placeholder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(),
            title: Text('Carregando membro...'),
          );
        }

        // Se deu erro ou o documento não foi encontrado
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.error)),
            title: Text('Membro não encontrado'),
          );
        }

        // Se deu tudo certo, extraímos os dados e montamos o card
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final displayName = userData['displayName'] ?? 'Nome não encontrado';
        final email = userData['email'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(email),
          ),
        );
      },
    );
  }
}
