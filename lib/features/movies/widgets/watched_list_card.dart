import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/widgets/movie_card.dart';
import 'package:intl/intl.dart';
import '../screens/movie_details_screen.dart';

class WatchedListCard extends StatelessWidget {
  final Movie movie;
  final String queueId;

  const WatchedListCard({
    super.key,
    required this.movie,
    required this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    return MovieCard(
      movie: movie,
      subtitle: Text(
        movie.watchedAt != null
            ? 'Assistido em: ${DateFormat('dd/MM/yyyy').format(movie.watchedAt!)}'
            : 'Data de visualização não informada',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movie: movie,
              queueId: queueId,
              showAddButton: false,
              showRemoveButton: true, // Lógica de assistido
              watched: true,
            ),
          ),
        );
      },
    );
  }
}
