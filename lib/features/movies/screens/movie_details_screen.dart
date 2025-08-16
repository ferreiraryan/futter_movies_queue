import 'package:flutter/material.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final bool showAddButton;
  final String? queueId;
  final bool showRemoveButton;
  final bool watched;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    this.queueId,
    this.showAddButton = true,
    this.showRemoveButton = false,
    required this.watched,
  });

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Widget? _buildBottomButton(BuildContext context) {
    if (widget.showAddButton) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Adicionar à Fila',
          onPressed: () async {
            final queueId = widget.queueId;
            if (queueId == null) {
              _showErrorSnackbar(
                "Erro: Fila não identificada para adicionar o filme.",
              );
              return;
            }
            Navigator.pop(context, false);
            try {
              await _firestoreService.addMovieToUpcoming(
                widget.movie,
                widget.queueId!,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.movie.title} adicionado!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
            }
          },
        ),
      );
    }
    if (widget.showRemoveButton) {
      if (widget.watched) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: 'Remover dos Assistidos',
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              final queueId = widget.queueId;
              if (queueId == null) {
                _showErrorSnackbar(
                  "Erro: Fila não identificada para remover o filme.",
                );
                return;
              }
              Navigator.pop(context);
              await _firestoreService.removeMovieFromWatched(
                widget.movie,
                queueId,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.movie.title} removido dos assistidos.',
                  ),
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
              final queueId = widget.queueId;

              if (queueId == null) {
                _showErrorSnackbar(
                  "Erro: Fila não identificada para remover o filme.",
                );
                return;
              }
              Navigator.pop(context);
              await _firestoreService.removeMovieFromUpcoming(
                widget.movie,
                queueId,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.movie.title} removido dos assistidos.',
                  ),
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
        title: Text(widget.movie.title),
        backgroundColor: AppColors.formBackground,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.movie.fullPosterUrl,
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
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Lançamento: ${widget.movie.releaseDate}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  if (widget.watched && widget.queueId != null)
                    RatingBar.builder(
                      initialRating: widget.movie.rating != null
                          ? widget.movie.rating!
                          : 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        _firestoreService.updateMovieRating(
                          widget.movie,
                          rating,
                          widget.queueId!,
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sinopse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
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
