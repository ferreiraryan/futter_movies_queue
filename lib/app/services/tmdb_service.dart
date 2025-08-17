import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/movies/models/movie_model.dart';

class TmdbService {
  static const String _apiKey = '9c8f21e1759485953bc9ab844b726a16';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> searchMovies(String query) async {
    // Se a busca estiver vazia, retorna uma lista vazia para não fazer chamadas desnecessárias
    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar filmes da API');
      }
    } catch (e) {
      print("Erro ao buscar filmes: $e");
      return [];
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=pt-BR',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // O endpoint de detalhes nos dá todos os campos que precisamos.
        // Vamos extraí-los e construir nosso objeto Movie completo.

        // A API retorna gêneros como uma lista de mapas [{'id': 1, 'name': 'Ação'}].
        // Nós extraímos apenas os nomes para a nossa List<String>.
        final List<String> genres = (data['genres'] as List)
            .map((genre) => genre['name'] as String)
            .toList();

        // Agora criamos o objeto Movie com TODOS os campos.
        return Movie(
          id: data['id'],
          title: data['title'],
          overview: data['overview'],
          posterPath: data['poster_path'] ?? '',
          releaseDate: data['release_date'] ?? '',
          // Campos ricos que acabamos de buscar:
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
      // Se der erro, lança a exceção para que a tela possa tratar
      throw Exception('Não foi possível buscar os detalhes do filme.');
    }
  }
}
