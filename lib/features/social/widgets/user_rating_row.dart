import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class UserRatingRow extends StatefulWidget {
  final String userId;
  final double rating;
  final Movie movie; // <<< NOVO: Precisa do filme para atualizar a nota
  final String queueId; // <<< NOVO: E do ID da fila

  const UserRatingRow({
    super.key,
    required this.userId,
    required this.rating,
    required this.movie,
    required this.queueId,
  });

  @override
  State<UserRatingRow> createState() => _UserRatingRowState();
}

class _UserRatingRowState extends State<UserRatingRow> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Pega o ID do usuário atualmente logado
    final currentUserId = AuthService().currentUserId;
    final bool isCurrentUser = widget.userId == currentUserId;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestoreService.getUserDocById(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Carregando...'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final displayName = userData['displayName'] ?? 'Usuário desconhecido';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // <<< LÓGICA CONDICIONAL AQUI >>>
              // Se for o usuário logado, mostra a barra interativa
              if (isCurrentUser)
                RatingBar.builder(
                  initialRating: widget.rating,
                  minRating: 0.5,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (newRating) {
                    _firestoreService.updateMovieRating(
                      widget.movie,
                      widget.userId,
                      newRating,
                      widget.queueId,
                    );
                  },
                )
              // Se não for, mostra a barra estática
              else
                RatingBarIndicator(
                  rating: widget.rating,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
            ],
          ),
        );
      },
    );
  }
}
