import 'package:flutter/material.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final bool showAddButton;
  final bool showRemoveButton;
  final bool watched;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.showAddButton = true,
    this.showRemoveButton = false,
    required this.watched,
  });

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Movie movie;
  late bool showAddButton;
  late bool showRemoveButton;
  late bool watched;

  @override
  void initState() {
    super.initState();
    movie = widget.movie;
    showAddButton = widget.showAddButton;
    showRemoveButton = widget.showRemoveButton;
    watched = widget.watched;
  }

  Widget? _buildBottomButton(BuildContext context) {
    if (showAddButton) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Adicionar à Fila',
          onPressed: () async {
            Navigator.pop(context, false);
            final success = await _firestoreService.addMovieToUpcoming(movie);
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${movie.title} adicionado à lista!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Este filme já está na sua lista ou já foi assistido.',
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
            }
          },
        ),
      );
    }
    if (showRemoveButton) {
      if (watched) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: 'Remover dos Assistidos',
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.removeMovieFromWatched(movie);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${movie.title} removido dos assistidos.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: 'Remover dos Proximos',
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.removeMovieFromUpcoming(movie);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${movie.title} removido dos assistidos.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: AppColors.formBackground,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              movie.fullPosterUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox(
                height: 300,
                child: Center(
                  child: Icon(Icons.movie, size: 100, color: Colors.grey),
                ),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Lançamento: ${movie.releaseDate}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  if (watched)
                    RatingBar.builder(
                      initialRating: movie.rating != null ? movie.rating! : 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        _firestoreService.updateMovieRating(movie, rating);
                      },
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sinopse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'Sinopse não disponível.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }
}
