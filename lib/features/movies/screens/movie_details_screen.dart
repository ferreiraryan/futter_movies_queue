import 'package:flutter/material.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/movie_model.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final bool showAddButton; // NOVO: Flag para controlar a visibilidade do botão
  final FirestoreService _firestoreService = FirestoreService();

  MovieDetailsScreen({
    super.key,
    required this.movie,
    this.showAddButton = true, // Padrão é mostrar o botão
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: AppColors.background,
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
      // Mostra o botão apenas se showAddButton for true
      bottomNavigationBar: showAddButton
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: 'Adicionar à Fila',
                onPressed: () async {
                  final success = await _firestoreService.addMovieToUpcoming(
                    movie,
                  );
                  if (!context.mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${movie.title} adicionado à lista!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
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
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : null,
    );
  }
}

