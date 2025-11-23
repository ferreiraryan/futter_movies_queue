import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_queue/features/movies/models/movie_model.dart';

class TmdbService {
  final String _apiKey =
      '9c8f21e1759485953bc9ab844b726a16'; // Mantenha sua chave!
  final String _baseUrl = 'https://api.themoviedb.org/3';

  /// Busca filmes por texto, com opção de filtrar por ano
  Future<List<Movie>> searchMovies(String query, {String? year}) async {
    if (query.isEmpty) {
      return [];
    }

    // Monta a URL base
    String urlString =
        '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR';

    // <<< NOVO: Adiciona o ano se ele foi passado >>>
    if (year != null && year.isNotEmpty) {
      urlString += '&primary_release_year=$year';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar filmes da API');
      }
    } catch (e) {
      print("Erro em searchMovies: $e");
      return [];
    }
  }

  // ... (Mantenha o método getMovieDetails igualzinho estava)
  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=pt-BR',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<String> genres = (data['genres'] as List)
            .map((genre) => genre['name'] as String)
            .toList();

        return Movie(
          id: data['id'],
          title: data['title'],
          overview: data['overview'],
          posterPath: data['poster_path'] ?? '',
          releaseDate: data['release_date'] ?? '',
          runtime: data['runtime'],
          genres: genres,
          backdropPath: data['backdrop_path'],
          tmdbRating: (data['vote_average'] as num?)?.toDouble(),
          tagline: data['tagline'],
        );
      } else {
        throw Exception('Falha ao carregar detalhes do filme');
      }
    } catch (e) {
      print("Erro em getMovieDetails: $e");
      throw Exception('Não foi possível buscar os detalhes do filme.');
    }
  }
}
