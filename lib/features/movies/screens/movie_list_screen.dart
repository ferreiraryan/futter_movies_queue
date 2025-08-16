import 'dart:async'; // <<< MUDANÇA: Import necessário para o StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/widgets/featured_movie_card.dart';
import 'package:movie_queue/features/movies/widgets/watched_list_card.dart';
import 'package:movie_queue/shared/widgets/main_background.dart';
import '../../../app/services/firestore_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../models/movie_model.dart';
import '../widgets/movie_list.dart';
import 'movie_search_screen.dart';

enum ScreenType { upcoming, watched }

class MovieListScreen extends StatefulWidget {
  final ScreenType screenType;
  final String queueId;
  const MovieListScreen({
    super.key,
    required this.screenType,
    required this.queueId,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late final StreamSubscription<DocumentSnapshot> _movieSubscription;
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
        .listen(
          (snapshot) {
            if (!mounted) return;

            List<Movie> newMovies = [];
            if (snapshot.exists && snapshot.data() != null) {
              final userData = snapshot.data() as Map<String, dynamic>;
              final movieDataList = (userData[listKey] as List<dynamic>?) ?? [];
              newMovies = movieDataList
                  .map((data) => Movie.fromMap(data as Map<String, dynamic>))
                  .toList();
            }

            setState(() {
              _movies = newMovies;
              _isLoading = false;
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              // Você pode adicionar uma variável de estado de erro aqui se quiser
            });
            // TODO: Lidar com o erro, talvez mostrando um SnackBar
          },
        );
  }

  @override
  void dispose() {
    _movieSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.screenType == ScreenType.upcoming;
    final String title = isUpcoming ? 'Próximos Filmes' : 'Últimos Filmes';

    if (_isLoading) {
      return _buildLoadingScaffold(title);
    }

    if (_movies.isEmpty) {
      return _buildEmptyScaffold(title, isUpcoming);
    }

    return MainBackground(
      appBar: _buildAppBar(title),
      drawer: const AppDrawer(),
      floatingActionButton: isUpcoming ? _buildFloatingActionButton() : null,
      header: isUpcoming
          ? FeaturedMovieCard(
              movie: _movies.first,
              queueId: widget.queueId,
              onMarkedAsWatched: () {
                _firestoreService.moveUpcomingToWatched(
                  _movies.first,
                  widget.queueId,
                );
              },
            )
          : null,
      body: isUpcoming ? _buildUpcomingBody() : _buildWatchedBody(),
    );
  }

  // --- MÉTODOS AUXILIARES ---

  Widget _buildUpcomingBody() {
    final reorderableMovies = _movies.sublist(1);
    return ReorderableMovieList(
      queueId: widget.queueId,
      key: const ValueKey('reorderable_list'),
      reorderableMovies: reorderableMovies,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final movie = _movies.removeAt(oldIndex + 1);
          _movies.insert(newIndex + 1, movie);
        });
        _firestoreService.updateUpcomingOrder(_movies, widget.queueId);
      },
    );
  }

  Widget _buildWatchedBody() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return WatchedListCard(
          queueId: widget.queueId,
          key: ValueKey(movie.id),
          movie: movie,
        );
      },
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.formBackground,
      centerTitle: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primaryColor),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddMovie,
      label: const Text(
        'Adicionar Filme',
        style: TextStyle(color: AppColors.buttonText),
      ),
      icon: const Icon(Icons.add, color: AppColors.buttonText),
      backgroundColor: AppColors.primaryColor,
    );
  }

  void _navigateToAddMovie() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MovieSearchScreen()),
    );
  }

  Widget _buildLoadingScaffold(String title) {
    return Scaffold(
      appBar: _buildAppBar(title),
      drawer: const AppDrawer(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text("Erro")),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Ocorreu um erro ao carregar os dados.')),
    );
  }

  Widget _buildEmptyScaffold(String title, bool isUpcoming) {
    return MainBackground(
      appBar: _buildAppBar(title),
      floatingActionButton: isUpcoming ? _buildFloatingActionButton() : null,
      body: const Center(child: Text('Nenhum filme nesta lista.')),
      drawer: const AppDrawer(),
    );
  }
}
