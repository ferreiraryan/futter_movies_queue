import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import 'package:movie_queue/features/movies/widgets/movie_card.dart';

class SearchListCard extends StatelessWidget {
  final Movie movie;

  const SearchListCard({super.key, required this.movie});

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
              showAddButton: true,
              showRemoveButton: false,
              watched: false,
            ),
          ),
        );
      },
      // Sem subtítulo aqui
    );
  }
}
