import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';

import '../../../shared/constants/app_colors.dart';
import '../models/movie_model.dart';

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onMarkedAsWatched;

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.onMarkedAsWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 40, right: 40),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  movie: movie,
                  showAddButton: false,
                  showRemoveButton: false,
                  watched: false,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                movie.fullPosterUrl,
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
                errorBuilder: (c, e, s) => const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.movie, color: Colors.grey)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
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
                      onPressed: onMarkedAsWatched,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryColor,
                      ),
                      label: const Text(
                        'Marcar como assistido',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
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
