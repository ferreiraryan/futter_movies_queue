import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

// ChangeNotifier é a classe do Flutter que nos permite "notificar" a UI sobre mudanças.
class SocialViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Guarda o ID da fila que este ViewModel está gerenciando.
  late String queueId;

  // Estado da UI
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Dados Calculados (os resultados que a UI vai exibir)
  Map<String, dynamic>? topRatedResult;
  Map<String, int> scoreboardStats = {};
  Map<String, Map<String, dynamic>> membersData = {};
  List<String> memberIds = [];

  // <<< NOVAS PROPRIEDADES PARA ESTATÍSTICAS >>>
  int watchedMovieCount = 0;
  int totalMinutes = 0;

  StreamSubscription? _queueSubscription;

  void listenToQueue(String queueId) {
    // Guarda o ID da fila assim que o listener é iniciado.
    this.queueId = queueId;

    _queueSubscription?.cancel();

    _queueSubscription = _firestoreService.getQueueStream(queueId).listen((
      queueSnapshot,
    ) async {
      if (!queueSnapshot.exists) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // --- TODA A LÓGICA DE DADOS E CÁLCULO FICA AQUI ---
      final queueData = queueSnapshot.data() as Map<String, dynamic>;

      memberIds = List<String>.from(queueData['members'] ?? []);
      final watchedMoviesRaw = queueData['watched_movies'] ?? [];
      final upcomingMoviesRaw = queueData['upcoming_movies'] ?? [];

      // <<< CÁLCULO DAS ESTATÍSTICAS ADICIONADO AQUI >>>
      watchedMovieCount = watchedMoviesRaw.length;
      totalMinutes = watchedMoviesRaw.fold(0, (sum, movieData) {
        final runtime = (movieData['runtime'] ?? 0) as int;
        return sum + runtime;
      });

      membersData = await _getAllMemberData(memberIds);
      topRatedResult = _findTopRatedMovie(watchedMoviesRaw);

      final allMovies = [
        ...upcomingMoviesRaw.map((data) => Movie.fromMap(data)),
        ...watchedMoviesRaw.map((data) => Movie.fromMap(data)),
      ];
      scoreboardStats = _calculateScoreboard(allMovies, membersData);

      _isLoading = false;
      notifyListeners();
    });
  }

  // --- MÉTODOS DE CÁLCULO ---

  Map<String, int> _calculateScoreboard(
    List<dynamic> allMovies,
    Map<String, Map<String, dynamic>> membersData,
  ) {
    final stats = <String, int>{};
    for (var movie in allMovies) {
      if (movie.addedBy != null) {
        final userName =
            membersData[movie.addedBy!]?['displayName'] ?? 'Desconhecido';
        stats[userName] = (stats[userName] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, dynamic>? _findTopRatedMovie(List<dynamic> watchedMoviesRaw) {
    if (watchedMoviesRaw.isEmpty) return null;
    Movie? topMovie;
    double maxAverage = 0.0;
    for (var movieData in watchedMoviesRaw) {
      final movie = Movie.fromMap(movieData);
      final ratings = movie.ratings;
      if (ratings != null && ratings.isNotEmpty) {
        double currentSum = ratings.values.reduce((a, b) => a + b);
        double currentAverage = currentSum / ratings.length;
        if (currentAverage > maxAverage) {
          maxAverage = currentAverage;
          topMovie = movie;
        }
      }
    }
    if (topMovie == null) return null;
    return {'movie': topMovie, 'averageRating': maxAverage};
  }

  Future<Map<String, Map<String, dynamic>>> _getAllMemberData(
    List<String> memberIds,
  ) async {
    if (memberIds.isEmpty) return {};
    final userDocs = await Future.wait(
      memberIds.map((id) => _firestoreService.getUserDocById(id)),
    );
    final data = <String, Map<String, dynamic>>{};
    for (var doc in userDocs) {
      if (doc.exists) {
        data[doc.id] = doc.data() as Map<String, dynamic>;
      }
    }
    return data;
  }

  @override
  void dispose() {
    _queueSubscription?.cancel();
    super.dispose();
  }
}
