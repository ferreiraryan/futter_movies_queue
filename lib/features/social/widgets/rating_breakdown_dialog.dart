// lib/features/social/widgets/rating_breakdown_dialog.dart

import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/social/widgets/user_rating_row.dart';

class RatingBreakdownDialog extends StatelessWidget {
  final Movie movie;
  final String queueId;
  const RatingBreakdownDialog({
    super.key,
    required this.movie,
    required this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    // Pega o mapa de notas do filme. Se for nulo, usa um mapa vazio.
    final ratingsMap = movie.ratings ?? {};

    return AlertDialog(
      title: Text('Notas para "${movie.title}"'),
      content: SizedBox(
        width: double.maxFinite, // Faz o dialog usar a largura disponível
        // Se não houver notas, mostra uma mensagem
        child: ratingsMap.isEmpty
            ? const Text('Ninguém avaliou este filme ainda.')
            : ListView.builder(
                shrinkWrap:
                    true, // Garante que a lista não cresça infinitamente
                itemCount: ratingsMap.length,
                itemBuilder: (context, index) {
                  // Pega o ID do usuário e a nota de cada item do mapa
                  final userId = ratingsMap.keys.elementAt(index);
                  final rating = ratingsMap.values.elementAt(index);
                  return UserRatingRow(
                    userId: userId,
                    rating: rating,
                    movie: movie,
                    queueId: queueId,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
