import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class UpcomingMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final int index; // <<< NOVO: Precisamos do índice para o listener

  const UpcomingMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.index, // <<< NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // <<< MUDANÇA PRINCIPAL AQUI >>>
              // Envolvemos o ícone com um listener que inicia o gesto de arrastar.
              ReorderableDragStartListener(
                index: index, // Informa à lista qual item está sendo arrastado
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.fullPosterUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
