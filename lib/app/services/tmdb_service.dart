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
}
