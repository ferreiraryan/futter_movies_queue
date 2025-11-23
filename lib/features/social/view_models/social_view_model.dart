import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class SocialViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  late String queueId;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? topRatedResult;
  Map<String, int> scoreboardStats = {};
  Map<String, Map<String, dynamic>> membersData = {};
  List<String> memberIds = [];
  int watchedMovieCount = 0;
  int totalMinutes = 0;

  
  int currentGoal = 50;
  DateTime? goalEndDate; 

  String? enthusiastId;
  double enthusiastAvg = 0.0;
  String? criticId;
  double criticAvg = 0.0;

  StreamSubscription? _queueSubscription;

  void listenToQueue(String queueId) {
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

      final queueData = queueSnapshot.data() as Map<String, dynamic>;

      
      currentGoal = (queueData['goal'] as num?)?.toInt() ?? 50;
      final Timestamp? endDateTs = queueData['goalEndDate'];
      goalEndDate = endDateTs?.toDate();

      memberIds = List<String>.from(queueData['members'] ?? []);
      final watchedMoviesRaw = queueData['watched_movies'] ?? [];
      final upcomingMoviesRaw = queueData['upcoming_movies'] ?? [];

      watchedMovieCount = watchedMoviesRaw.length;
      totalMinutes = watchedMoviesRaw.fold(0, (sum, movieData) {
        final runtime = (movieData['runtime'] ?? 0) as int;
        return sum + runtime;
      });

      membersData = await _getAllMemberData(memberIds);
      topRatedResult = _findTopRatedMovie(watchedMoviesRaw);

      final List<Movie> allMovies = [
        ...upcomingMoviesRaw.map((data) => Movie.fromMap(data)),
        ...watchedMoviesRaw.map((data) => Movie.fromMap(data)),
      ];
      scoreboardStats = _calculateScoreboard(allMovies, membersData);

      _calculatePersonalities(watchedMoviesRaw);

      _isLoading = false;
      notifyListeners();
    });
  }

  
  void _calculatePersonalities(List<dynamic> watchedMoviesRaw) {
    final userRatings = <String, List<double>>{};
    for (var movieData in watchedMoviesRaw) {
      final movie = Movie.fromMap(movieData);
      if (movie.ratings != null) {
        movie.ratings!.forEach((userId, rating) {
          if (!userRatings.containsKey(userId)) {
            userRatings[userId] = [];
          }
          userRatings[userId]!.add(rating);
        });
      }
    }
    String? tempEnthusiastId;
    double maxAvg = -1.0;
    String? tempCriticId;
    double minAvg = 11.0;
    userRatings.forEach((userId, ratings) {
      if (ratings.isEmpty) return;
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      if (avg > maxAvg) {
        maxAvg = avg;
        tempEnthusiastId = userId;
      }
      if (avg < minAvg) {
        minAvg = avg;
        tempCriticId = userId;
      }
    });
    if (tempEnthusiastId != null) {
      enthusiastId = tempEnthusiastId;
      enthusiastAvg = maxAvg;
      criticId = tempCriticId;
      criticAvg = minAvg;
    } else {
      enthusiastId = null;
      criticId = null;
    }
  }

  Map<String, int> _calculateScoreboard(
    List<Movie> allMovies,
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
