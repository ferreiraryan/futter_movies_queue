import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import 'package:movie_queue/features/movies/screens/movie_search_screen.dart';
import 'package:movie_queue/features/movies/widgets/featured_movie_card.dart';
import 'package:movie_queue/features/movies/widgets/upcoming_movie_card.dart';
import 'package:movie_queue/features/movies/widgets/watched_movie_card.dart';
import 'package:movie_queue/shared/widgets/app_drawer.dart'; // Criaremos em breve

// Enum para definir o tipo de lista a ser exibida
enum ScreenType { upcoming, watched }

class MovieListScreen extends StatefulWidget {
  final String queueId;
  final ScreenType screenType;

  const MovieListScreen({
    super.key,
    required this.queueId,
    required this.screenType,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late StreamSubscription<DocumentSnapshot> _movieSubscription;

  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToMovieChanges();
  }

  void _listenToMovieChanges() {
    final String listKey = widget.screenType == ScreenType.upcoming
        ? 'upcoming_movies'
        : 'watched_movies';

    _movieSubscription = _firestoreService
        .getQueueStream(widget.queueId)
        .listen((snapshot) {
          if (!mounted) return; // Garante que o widget ainda está na tela

          List<Movie> newMovies = [];
          if (snapshot.exists && snapshot.data() != null) {
            final queueData = snapshot.data() as Map<String, dynamic>;
            // Pega a lista de filmes (upcoming ou watched) do documento da fila
            final movieDataList = (queueData[listKey] as List<dynamic>?) ?? [];
            newMovies = movieDataList
                .map((data) => Movie.fromMap(data))
                .toList();
          }

          setState(() {
            _movies = newMovies;
            _isLoading = false;
          });
        });
  }

  @override
  void dispose() {
    _movieSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.screenType == ScreenType.upcoming
        ? 'Próximos Filmes'
        : 'Filmes Assistidos';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: AppDrawer(queueId: widget.queueId),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieSearchScreen(queueId: widget.queueId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'Nenhum filme nesta lista ainda.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }

    if (widget.screenType == ScreenType.watched) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];

          // <<< MUDANÇA PRINCIPAL AQUI >>>
          // Substituímos o ListTile pelo nosso novo card
          return WatchedMovieCard(movie: movie, queueId: widget.queueId);
        },
      );
    }

    // Se a lista for de "próximos", usa o novo layout
    final featuredMovie = _movies.first;
    final upcomingList = _movies.length > 1 ? _movies.sublist(1) : [];

    return CustomScrollView(
      slivers: [
        // 1. Card de Destaque
        SliverToBoxAdapter(
          child: FeaturedMovieCard(
            movie: featuredMovie,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    movie: featuredMovie,
                    queueId: widget.queueId,
                    context: MovieDetailsContext.upcoming,
                  ),
                ),
              );
            },
            onMarkAsWatched: () {
              _firestoreService.moveUpcomingToWatched(
                featuredMovie,
                widget.queueId,
              );
            },
          ),
        ),

        // 2. Título da Próxima Fila
        SliverToBoxAdapter(
          child: upcomingList.isNotEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Próximos na Fila',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // 3. Lista Reordenável
        SliverReorderableList(
          // O itemCount é o total de filmes menos o que está em destaque.
          itemCount: _movies.length - 1,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            // Buscamos o filme na lista principal, mas pulando o primeiro.
            // Ex: O item 0 da lista arrastável é o item 1 da _movies.
            final movie = _movies[index + 1];

            return UpcomingMovieCard(
              // A Key é essencial e já estava correta.
              key: ValueKey(movie.id),
              movie: movie,
              index: index,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(
                      movie: movie,
                      queueId: widget.queueId,
                      context: MovieDetailsContext.upcoming,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ... dentro da classe _MovieListScreenState

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      final Movie item = _movies.removeAt(oldIndex + 1);
      _movies.insert(newIndex + 1, item);
    });
    _firestoreService.updateUpcomingOrder(_movies, widget.queueId);
  }
}
