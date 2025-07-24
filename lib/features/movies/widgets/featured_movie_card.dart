import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/movie_model.dart';

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onMarkedAsWatched; // NOVO: Callback

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.onMarkedAsWatched, // NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // ... (estilo do card permanece o mesmo)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            movie.fullPosterUrl,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (c, e, s) => const SizedBox(
              height: 200,
              child: Center(child: Icon(Icons.movie, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onMarkedAsWatched, // ATUALIZADO: Usa o callback
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.buttonBackground,
                  ),
                  label: const Text(
                    'Marcar como assistido',
                    style: TextStyle(color: AppColors.buttonBackground),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
