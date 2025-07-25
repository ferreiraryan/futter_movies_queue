import 'dart:async'; // Import necessário para usar o Timer

import 'package:flutter/material.dart';
import 'package:movie_queue/features/movies/widgets/movie_card.dart';
import 'package:movie_queue/features/movies/widgets/search_list_card.dart';
import 'package:movie_queue/shared/widgets/main_background.dart';

import '../../../app/services/tmdb_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/movie_model.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});
  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String _message = 'Digite o nome de um filme para buscar.';

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      appBar: AppBar(
        title: const Text('Buscar Filme'),
        backgroundColor: AppColors.formBackground,
      ),
      header: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          onChanged: _onSearchChanged,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ex: Matrix, Duna, Interestelar...',
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      body: _searchResults.isEmpty
          ? Center(child: Text(_message))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
                return SearchListCard(movie: movie);
              },
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _message = 'Digite o nome de um filme para buscar.';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        final results = await _tmdbService.searchMovies(query);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          if (results.isEmpty) {
            _message = 'Nenhum resultado encontrado para "$query".';
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _message = 'Erro ao buscar filmes. Tente novamente.';
        });
      } finally {
        // ignore: control_flow_in_finally
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
