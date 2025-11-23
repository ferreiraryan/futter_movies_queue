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
  final TextEditingController _yearController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String? _selectedYear; 

  void _performSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    
    final results = await _tmdbService.searchMovies(query, year: _selectedYear);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Busca'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Ano de Lançamento',
                  hintText: 'Ex: 2023',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                
                _yearController.clear();
                setState(() {
                  _selectedYear = null;
                });
                Navigator.pop(context);
                _performSearch(); 
              },
              child: const Text('Limpar Filtros'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedYear = _yearController.text.isNotEmpty
                      ? _yearController.text
                      : null;
                });
                Navigator.pop(context);
                _performSearch(); 
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
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
          onChanged: (val) => _performSearch(),
        ),
        actions: [
          
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedYear != null ? Colors.deepPurpleAccent : null,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          
          if (_selectedYear != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Ano: $_selectedYear'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedYear = null;
                    _yearController.clear();
                  });
                  _performSearch();
                },
              ),
            ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
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
      padding: const EdgeInsets.only(top: 10, bottom: 10),
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
