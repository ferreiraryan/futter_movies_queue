import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<bool> addMovieToUpcoming(Movie movie) async {
    if (_userId == null) return false;
    final docRef = _db.collection('users').doc(_userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final upcomingMovies = (data['upcoming_movies'] as List<dynamic>?) ?? [];
      if (upcomingMovies.any((m) => m['id'] == movie.id)) {
        return false;
      }
      final watchedMovies = (data['watched_movies'] as List<dynamic>?) ?? [];
      if (watchedMovies.any((m) => m['id'] == movie.id)) {
        return false;
      }
    }

    await docRef.set({
      'upcoming_movies': FieldValue.arrayUnion([movie.toMap()]),
    }, SetOptions(merge: true));
    return true;
  }

  Future<void> moveUpcomingToWatched(Movie movie) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    final watchedMovieMap = {
      ...movie.toMap(),
      'watched_date': Timestamp.fromDate(dateOnly),
    };

    await docRef.update({
      'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),

      'watched_movies': FieldValue.arrayUnion([watchedMovieMap]),
    });
  }

  Future<void> removeMovieFromWatched(Movie movie) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);

    final Map<String, dynamic> movieMap = movie.toMap();

    if (movie.watchedDate != null) {
      movieMap['watched_date'] = Timestamp.fromDate(movie.watchedDate!);
    }

    await docRef.update({
      'watched_movies': FieldValue.arrayRemove([movieMap]),
    });
  }

  Future<void> removeMovieFromUpcoming(Movie movie) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);
    await docRef.update({
      'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
    });
  }

  Future<void> updateUpcomingOrder(List<Movie> movies) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);
    final List<Map<String, dynamic>> movieMaps = movies
        .map((m) => m.toMap())
        .toList();
    await docRef.update({'upcoming_movies': movieMaps});
  }

  Stream<DocumentSnapshot> getUserDocStream() {
    if (_userId == null) return const Stream.empty();
    return _db.collection('users').doc(_userId).snapshots();
  }

  Future<void> updateMovieRating(Movie movie, double newRating) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = await docRef.get();

      final List<dynamic> watchedMovies = List.from(
        data['watched_movies'] ?? [],
      );

      final int movieIndex = watchedMovies.indexWhere(
        (m) => m['id'] == movie.id,
      );

      if (movieIndex != -1) {
        watchedMovies[movieIndex]['rating'] = newRating;

        await docRef.update({'watched_movies': watchedMovies});
      }
    }
  }
}
