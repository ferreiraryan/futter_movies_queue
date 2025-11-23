import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onMarkAsWatched;
  final VoidCallback onTap;

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.onMarkAsWatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            
            Hero(
              tag: 'backdrop-${movie.id}',
              child: Image.network(
                
                movie.fullBackdropUrl, 
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.movie, size: 60)),
                ),
              ),
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onMarkAsWatched,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Assistido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
