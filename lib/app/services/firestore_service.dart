import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ATUALIZADO: Agora retorna um booleano indicando sucesso ou falha.
  Future<bool> addMovieToUpcoming(Movie movie) async {
    if (_userId == null) return false;
    final docRef = _db.collection('users').doc(_userId);
    final docSnapshot = await docRef.get();

    // Verifica se o documento do usuário existe e tem dados
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      // Verifica se o filme já está na lista de "próximos"
      final upcomingMovies = (data['upcoming_movies'] as List<dynamic>?) ?? [];
      if (upcomingMovies.any((m) => m['id'] == movie.id)) {
        print("Filme já está na lista de próximos.");
        return false;
      }

      // Verifica se o filme já está na lista de "assistidos"
      final watchedMovies = (data['watched_movies'] as List<dynamic>?) ?? [];
      if (watchedMovies.any((m) => m['id'] == movie.id)) {
        print("Filme já foi assistido.");
        return false;
      }
    }

    // Se passou por todas as verificações, adiciona o filme.
    await docRef.set({
      'upcoming_movies': FieldValue.arrayUnion([movie.toMap()]),
    }, SetOptions(merge: true));
    return true;
  }

  Future<void> moveUpcomingToWatched(Movie movie) async {
    if (_userId == null) return;
    final docRef = _db.collection('users').doc(_userId);
    await docRef.update({
      'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
      'watched_movies': FieldValue.arrayUnion([movie.toMap()]),
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
}
