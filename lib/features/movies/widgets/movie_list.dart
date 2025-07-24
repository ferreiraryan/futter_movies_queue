import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'featured_movie_card.dart';
import 'movie_list_item.dart';

class ReorderableMovieList extends StatelessWidget {
  final Movie featuredMovie;
  final List<Movie> reorderableMovies;
  final Function(int, int) onReorder;
  final VoidCallback onMarkedAsWatched;

  const ReorderableMovieList({
    super.key,
    required this.featuredMovie,
    required this.reorderableMovies,
    required this.onReorder,
    required this.onMarkedAsWatched,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      // O header é o nosso card de destaque, que não pode ser arrastado.
      header: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FeaturedMovieCard(
          movie: featuredMovie,
          onMarkedAsWatched: onMarkedAsWatched,
        ),
      ),
      itemCount: reorderableMovies.length,
      itemBuilder: (context, index) {
        final movie = reorderableMovies[index];
        // Cada item precisa de uma Key única para o Flutter saber quem é quem.
        return MovieListItem(key: ValueKey(movie.id), movie: movie);
      },
      onReorder: onReorder,
    );
  }
}

