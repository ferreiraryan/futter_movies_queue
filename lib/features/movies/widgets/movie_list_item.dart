import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/movie_model.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  const MovieListItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      // Altere a cor aqui
      color: AppColors.lightAccent.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(
                movie: movie,
                showAddButton: false,
                showRemoveButton: false,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 12, right: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 0,
            ),
            title: Text(
              movie.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(
              Icons.more_horiz,
              color: AppColors.formBackground,
            ),
          ),
        ),
      ),
    );
  }
}
