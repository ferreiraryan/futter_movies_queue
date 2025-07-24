import 'package:flutter/material.dart';
import '../../../app/services/tmdb_service.dart';
import '../models/movie_model.dart';
import '../../../shared/constants/app_colors.dart';
import 'movie_details_screen.dart';

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

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _message = 'Digite o nome de um filme para buscar.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await _tmdbService.searchMovies(query);
      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _message = 'Nenhum resultado encontrado para "$query".';
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Erro ao buscar filmes. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Filme'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: Matrix, Duna, Interestelar...',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(child: Text(_message))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = _searchResults[index];
                      return ListTile(
                        leading: Image.network(
                          movie.fullPosterUrl,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.movie, size: 50),
                        ),
                        title: Text(movie.title),
                        subtitle: Text(
                          movie.releaseDate.isNotEmpty
                              ? movie.releaseDate.substring(0, 4)
                              : 'N/A',
                        ),
                        onTap: () async {
                          // *** LÓGICA ATUALIZADA ***
                          // Navega para os detalhes e aguarda um resultado
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsScreen(movie: movie),
                            ),
                          );
                          // Se o resultado for 'true' (filme adicionado com sucesso),
                          // fecha também a tela de busca.
                          if (result == true && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

