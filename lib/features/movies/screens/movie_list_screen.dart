import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../models/movie_model.dart';
import '../widgets/movie_list.dart'; // Importa o novo widget
import 'movie_search_screen.dart';

enum ScreenType { upcoming, watched }

class MovieListScreen extends StatefulWidget {
  final ScreenType screenType;
  const MovieListScreen({super.key, required this.screenType});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.screenType == ScreenType.upcoming;
    final title = isUpcoming ? 'Próximos Filmes' : 'Últimos Filmes';
    final listKey = isUpcoming ? 'upcoming_movies' : 'watched_movies';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.background)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.background),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getUserDocStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Adicione seu primeiro filme!'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final movieDataList = (userData[listKey] as List<dynamic>?) ?? [];
          final movies = movieDataList
              .map((data) => Movie.fromMap(data as Map<String, dynamic>))
              .toList();

          if (movies.isEmpty) {
            return const Center(child: Text('Nenhum filme nesta lista.'));
          }

          // Lógica para a tela de "Próximos Filmes" com reordenação
          if (isUpcoming) {
            final featuredMovie = movies.first;
            final reorderableMovies = movies.sublist(1);

            return ReorderableMovieList(
              featuredMovie: featuredMovie,
              reorderableMovies: reorderableMovies,
              onMarkedAsWatched: () {
                _firestoreService.moveUpcomingToWatched(featuredMovie);
              },
              onReorder: (oldIndex, newIndex) {
                // *** LÓGICA CORRIGIDA ***
                // Não usamos mais setState aqui. Apenas manipulamos a lista
                // e enviamos para o Firestore. O StreamBuilder cuidará da UI.

                // Cria uma cópia mutável da lista que pode ser reordenada
                final List<Movie> mutableReorderableMovies = List.from(
                  reorderableMovies,
                );

                // Ajusta o índice para a lista 'reorderableMovies'
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }

                // Remove o item da posição antiga e insere na nova
                final movie = mutableReorderableMovies.removeAt(oldIndex);
                mutableReorderableMovies.insert(newIndex, movie);

                // Cria a lista completa e salva no Firestore
                final fullNewList = [
                  featuredMovie,
                  ...mutableReorderableMovies,
                ];
                _firestoreService.updateUpcomingOrder(fullNewList);
              },
            );
          } else {
            // Para a tela de "Assistidos", usamos a lista simples (sem reordenar)
            // TODO: Criar um widget de lista simples para os assistidos.
            // Por enquanto, mostra uma lista básica.
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(title: Text(movie.title));
              },
            );
          }
        },
      ),
      floatingActionButton: isUpcoming
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovieSearchScreen(),
                  ),
                );
              },
              label: const Text('Adicionar Filme'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.buttonBackground,
            )
          : null,
    );
  }
}
