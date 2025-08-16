import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/widgets/movie_card.dart';

import '../screens/movie_details_screen.dart';

class UpcomingListCard extends StatelessWidget {
  final Movie movie;
  final String queueId;

  const UpcomingListCard({
    super.key,
    required this.movie,
    required this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    return MovieCard(
      movie: movie,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movie: movie,
              queueId: queueId,
              showAddButton: false,
              showRemoveButton: true, // Lógica de assistido
              watched: false,
            ),
          ),
        );
      },
    );
  }
}
