import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import necessário
import 'package:movie_queue/features/movies/models/movie_model.dart';

class WatchedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final String queueId;

  const WatchedMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = 'Data desconhecida';
    if (movie.watchedAt != null) {
      formattedDate = DateFormat('dd/MM/yyyy').format(movie.watchedAt!);
    }

    // <<< CÁLCULO DA MÉDIA >>>
    double averageRating = 0.0;
    if (movie.ratings != null && movie.ratings!.isNotEmpty) {
      double sum = movie.ratings!.values.reduce((a, b) => a + b);
      averageRating = sum / movie.ratings!.length;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Boas práticas de UI
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'poster-watched-${movie.id}', // Tag única para o Hero
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
                    // <<< EXIBIÇÃO DAS ESTRELAS (MÉDIA) >>>
                    if (averageRating > 0)
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: averageRating,
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 16.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Sem avaliações',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Assistido em $formattedDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
