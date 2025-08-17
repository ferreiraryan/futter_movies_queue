import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import para formatação de data
import 'package:movie_queue/features/movies/models/movie_model.dart';

class WatchedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const WatchedMovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Formata a data para o padrão dd/MM/yyyy
    String formattedDate = 'Assistido em data desconhecida';
    if (movie.watchedAt != null) {
      // Usamos o DateFormat do pacote intl
      formattedDate =
          'Assistido em ${DateFormat('dd/MM/yyyy').format(movie.watchedAt!)}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Imagem do Pôster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.fullPosterUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 70,
                    height: 100,
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informações (Título e Data)
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
                    const SizedBox(height: 8),
                    Text(
                      formattedDate, // <<< NOSSA DATA FORMATADA AQUI
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
