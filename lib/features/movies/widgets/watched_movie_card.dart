import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../screens/movie_details_screen.dart';

class WatchedMovieCard extends StatelessWidget {
  final Movie movie;

  const WatchedMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(
                movie: movie,
                showAddButton: false, // Não mostra o botão de adicionar
                showRemoveButton: true, // Mostra o botão de remover
              ),
            ),
          );
        },
        child: Row(
          children: [
            Image.network(
              movie.fullPosterUrl,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox(
                width: 80,
                height: 120,
                child: Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assistido em: (data futura)',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.info_outline, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
