import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import '../models/movie_model.dart';

// Widget base, puramente visual e reutilizável
class MovieCard extends StatelessWidget {
  final Movie movie;
  final Widget? subtitle; // Subtítulo opcional
  final VoidCallback onTap; // Ação ao tocar

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
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
