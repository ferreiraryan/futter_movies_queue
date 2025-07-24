import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../models/movie_model.dart';
import '../widgets/movie_list.dart';
import '../widgets/watched_movie_card.dart';
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
  // NOVO: Variável de estado para gerenciar a lista localmente
  List<Movie> _movies = [];

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
          if (snapshot.connectionState == ConnectionState.waiting &&
              _movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro.'));
          }
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final movieDataList = (userData[listKey] as List<dynamic>?) ?? [];
            // ATUALIZA a lista local com os dados do Firebase
            _movies = movieDataList
                .map((data) => Movie.fromMap(data as Map<String, dynamic>))
                .toList();
          }

          if (_movies.isEmpty) {
            return const Center(child: Text('Nenhum filme nesta lista.'));
          }

          if (isUpcoming) {
            final featuredMovie = _movies.first;
            final reorderableMovies = _movies.sublist(1);

            return ReorderableMovieList(
              featuredMovie: featuredMovie,
              reorderableMovies: reorderableMovies,
              onMarkedAsWatched: () {
                _firestoreService.moveUpcomingToWatched(featuredMovie);
              },
              onReorder: (oldIndex, newIndex) {
                // LÓGICA CORRIGIDA
                setState(() {
                  // Ajusta o índice para a lista reordenável
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  // Remove o filme da lista principal usando o índice ajustado
                  final movie = _movies.removeAt(oldIndex + 1);
                  // Insere na nova posição, também ajustada
                  _movies.insert(newIndex + 1, movie);
                });
                // Salva a nova ordem completa no Firestore
                _firestoreService.updateUpcomingOrder(_movies);
              },
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return WatchedMovieCard(movie: movie);
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

