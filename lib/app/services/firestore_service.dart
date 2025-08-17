// lib/app/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<DocumentSnapshot> getUserDocStream() {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado");
    return _db.collection('users').doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> getQueueStream(String queueId) {
    return _db.collection('queues').doc(queueId).snapshots();
  }

  Future<void> createInitialDataForUser(User user, String displayName) async {
    final newQueueRef = _db.collection('queues').doc();
    await newQueueRef.set({
      'ownerId': user.uid,
      'members': [user.uid],
      'upcoming_movies': [],
      'watched_movies': [],
    });

    // 2. Cria o documento do usuário e aponta para a fila criada
    await _db.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'email': user.email,
      'activeQueueId': newQueueRef.id,
    });
  }

  // --- Funções de manipulação de filmes (agora operam na fila) ---
  Future<void> updateMovieRating(
    Movie movieToUpdate,
    String userId,
    double newRating,
    String queueId,
  ) async {
    final docRef = _db.collection('queues').doc(queueId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final List<dynamic> watchedListRaw = (doc.data()!)['watched_movies'] ?? [];
    List<Movie> watchedList = watchedListRaw
        .map((data) => Movie.fromMap(data))
        .toList();

    final int movieIndex = watchedList.indexWhere(
      (m) => m.id == movieToUpdate.id,
    );

    if (movieIndex != -1) {
      final Movie oldMovie = watchedList[movieIndex];

          final Map<String, double> updatedRatings = Map.from(
        oldMovie.ratings ?? {},
      );

      // 4. Atualiza a nota para o usuário específico.
      updatedRatings[userId] = newRating;

      // 5. Cria uma nova instância do filme com o mapa de notas atualizado.
      final Movie updatedMovie = oldMovie.copyWith(ratings: updatedRatings);

      // 6. Substitui o filme antigo pelo novo na lista.
      watchedList[movieIndex] = updatedMovie;

      // 7. Salva a lista inteira de volta no Firestore.
      final List<Map<String, dynamic>> finalMovieMaps = watchedList
          .map((m) => m.toMap())
          .toList();
      await docRef.update({'watched_movies': finalMovieMaps});
    }
  }

  Future<void> addMovieToUpcoming(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);
    await docRef.update({
      'upcoming_movies': FieldValue.arrayUnion([movie.toMap()]),
    });
  }

  Future<void> moveUpcomingToWatched(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);
    final watchedMovie = movie.copyWith(watchedAt: DateTime.now());
    await docRef.update({
      'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
      'watched_movies': FieldValue.arrayUnion([watchedMovie.toMap()]),
    });
  }

  Future<void> updateUpcomingOrder(List<Movie> movies, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);
    final List<Map<String, dynamic>> movieMaps = movies
        .map((m) => m.toMap())
        .toList();
    await docRef.update({'upcoming_movies': movieMaps});
  }

  Future<void> removeMovieFromUpcoming(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);
    await docRef.update({
      'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
    });
  }

  Future<void> removeMovieFromWatched(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);
    await docRef.update({
      'watched_movies': FieldValue.arrayRemove([movie.toMap()]),
    });
  }
}
