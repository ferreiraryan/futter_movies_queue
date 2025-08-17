// lib/features/movies/widgets/searched_movie_card.dart

import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class SearchedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const SearchedMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extrai o ano da data de lançamento de forma segura
    String releaseYear = 'N/A';
    if (movie.releaseDate.isNotEmpty && movie.releaseDate.length >= 4) {
      releaseYear = movie.releaseDate.substring(0, 4);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip
          .antiAlias, // Garante que o conteúdo respeite as bordas arredondadas
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Pôster
            Image.network(
              movie.fullPosterUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Widget que aparece se a imagem falhar ao carregar
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white, size: 40),
                  ),
                );
              },
            ),

            // Informações do Filme (Título e Ano)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      // Limita o título a 3 linhas e adiciona "..." se for muito grande
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      releaseYear,
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
