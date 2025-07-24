import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/movies/models/movie_model.dart';

class TmdbService {
  static const String _apiKey = '9c8f21e1759485953bc9ab844b726a16';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> searchMovies(String query) async {
    if (_apiKey == 'SUA_API_KEY_AQUI') {
      print(
        'ERRO: Por favor, adicione sua API Key do TMDb no arquivo tmdb_service.dart',
      );
      return [];
    }

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar filmes');
    }
  }
}
