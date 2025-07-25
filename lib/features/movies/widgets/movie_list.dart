import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'movie_card.dart';

class ReorderableMovieList extends StatelessWidget {
  final List<Movie> reorderableMovies;
  final Function(int, int) onReorder;

  const ReorderableMovieList({
    super.key,
    required this.reorderableMovies,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16),
      itemCount: reorderableMovies.length,
      itemBuilder: (context, index) {
        final movie = reorderableMovies[index];
        return MovieCard(
          key: ValueKey(movie.id),
          movie: movie,
          isWatched: false,
        );
      },
      onReorder: onReorder,
    );
  }
}
