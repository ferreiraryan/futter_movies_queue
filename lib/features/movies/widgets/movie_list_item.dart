import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/movie_model.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  const MovieListItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
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
        trailing: const Icon(Icons.more_horiz, color: AppColors.formBackground),
      ),
    );
  }
}

