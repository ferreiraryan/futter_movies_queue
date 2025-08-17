// lib/features/movies/screens/movie_search_screen.dart

import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/tmdb_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import 'package:movie_queue/features/movies/widgets/searched_movie_card.dart';

class MovieSearchScreen extends StatefulWidget {
  final String queueId;

  const MovieSearchScreen({super.key, required this.queueId});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await _tmdbService.searchMovies(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar filme...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isNotEmpty && _searchResults.isEmpty) {
      return const Center(child: Text('Nenhum filme encontrado.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ), // Adiciona um respiro na lista
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return SearchedMovieCard(
          movie: movie,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(
                  movie: movie,
                  queueId: widget.queueId,
                  context: MovieDetailsContext.search,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
