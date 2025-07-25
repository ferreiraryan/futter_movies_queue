import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/widgets/featured_movie_card.dart';
import 'package:movie_queue/shared/widgets/main_background.dart';
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

  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.screenType == ScreenType.upcoming;
    final String title = isUpcoming ? 'Próximos Filmes' : 'Últimos Filmes';
    final String listKey = isUpcoming ? 'upcoming_movies' : 'watched_movies';

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getUserDocStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _movies.isEmpty) {
          return _buildLoadingScaffold(title);
        }
        if (snapshot.hasError) {
          return _buildErrorScaffold();
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final movieDataList = (userData[listKey] as List<dynamic>?) ?? [];
          _movies = movieDataList
              .map((data) => Movie.fromMap(data as Map<String, dynamic>))
              .toList();
        }

        if (_movies.isEmpty) {
          return MainBackground(
            appBar: _buildAppBar(title),
            drawer: const AppDrawer(),
            floatingActionButton: isUpcoming
                ? _buildFloatingActionButton()
                : null,
            body: const Center(child: Text('Nenhum filme nesta lista.')),
          );
        }

        return MainBackground(
          appBar: _buildAppBar(title),
          drawer: const AppDrawer(),
          floatingActionButton: isUpcoming
              ? _buildFloatingActionButton()
              : null,

          header: isUpcoming
              ? FeaturedMovieCard(
                  movie: _movies.first,
                  onMarkedAsWatched: () {
                    _firestoreService.moveUpcomingToWatched(_movies.first);
                  },
                )
              : null,

          body: isUpcoming ? _buildUpcomingBody() : _buildWatchedBody(),
        );
      },
    );
  }

  Widget _buildUpcomingBody() {
    return ReorderableMovieList(
      reorderableMovies: _movies.sublist(1),
      onMarkedAsWatched: () {
        _firestoreService.moveUpcomingToWatched(_movies.first);
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final movie = _movies.removeAt(oldIndex + 1);
          _movies.insert(newIndex + 1, movie);
        });
        _firestoreService.updateUpcomingOrder(_movies);
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
        return WatchedMovieCard(movie: _movies[index]);
      },
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.formBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.background),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddMovie,
      label: const Text('Adicionar Filme'),
      icon: const Icon(Icons.add),
      backgroundColor: AppColors.lightAccent,
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
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text("Erro")),
      body: const Center(child: Text('Ocorreu um erro ao carregar os dados.')),
    );
  }

}
