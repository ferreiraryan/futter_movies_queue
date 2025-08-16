import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Métodos de Leitura (Streams) ---
  Stream<DocumentSnapshot> getQueueStream(String queueId) {
    return _db.collection('queues').doc(queueId).snapshots();
  }

  Stream<DocumentSnapshot> getUserDocStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");
    return _db.collection('users').doc(user.uid).snapshots();
  }

  // --- Métodos de Gerenciamento de Usuário e Fila ---
  Future<void> createInitialQueueForUser(User user, String displayName) async {
    final newQueueRef = _db.collection('queues').doc();
    await newQueueRef.set({
      'ownerId': user.uid,
      'members': [user.uid],
      'upcoming_movies': [],
      'watched_movies': [],
    });
    await _db.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'email': user.email,
      'activeQueueId': newQueueRef.id,
    });
  }

  Future<QuerySnapshot> findUserByName(String name) {
    return _db
        .collection('users')
        .where('displayName', isEqualTo: name)
        .limit(1)
        .get();
  }

  Future<void> shareQueueWithUser(String friendId, String queueId) async {
    final queueRef = _db.collection('queues').doc(queueId);
    await queueRef.update({
      'members': FieldValue.arrayUnion([friendId]),
    });
    final userRef = _db.collection('users').doc(friendId);
    await userRef.update({'activeQueueId': queueId});
  }

  // --- Métodos de Manipulação de Filmes (Otimizados) ---

  Future<void> addMovieToUpcoming(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Fila não existe!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final upcomingMovies = (data['upcoming_movies'] as List<dynamic>? ?? [])
          .map((m) => Movie.fromMap(m))
          .toList();
      final watchedMovies = (data['watched_movies'] as List<dynamic>? ?? [])
          .map((m) => Movie.fromMap(m))
          .toList();

      // Verifica se o filme já existe em qualquer uma das listas
      final alreadyExists =
          upcomingMovies.any((m) => m.id == movie.id) ||
          watchedMovies.any((m) => m.id == movie.id);

      if (alreadyExists) {
        // Lança uma exceção para sinalizar que o filme já existe.
        // O código na UI pode capturar isso e mostrar uma mensagem.
        throw Exception('Filme já existe na sua fila.');
      }

      // Se não existir, adiciona o filme
      transaction.update(docRef, {
        'upcoming_movies': FieldValue.arrayUnion([movie.toMap()]),
      });
    });
  }

  // <<< MUDANÇA: Adicionado try/catch e padronizado para Future<void>
  Future<void> moveUpcomingToWatched(Movie movie, String queueId) async {
    try {
      final docRef = _db.collection('queues').doc(queueId);
      await docRef.update({
        'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
        'watched_movies': FieldValue.arrayUnion([
          movie.copyWith(watchedAt: DateTime.now()).toMap(),
        ]),
      });
    } catch (e) {
      print('Erro ao mover filme para assistidos: $e');
      rethrow; // Re-lança o erro para a UI poder tratar
    }
  }

  Future<void> removeMovieFromUpcoming(Movie movie, String queueId) async {
    try {
      final docRef = _db.collection('queues').doc(queueId);
      await docRef.update({
        'upcoming_movies': FieldValue.arrayRemove([movie.toMap()]),
      });
    } catch (e) {
      print('Erro ao remover filme da fila: $e');
      rethrow;
    }
  }

  Future<void> removeMovieFromWatched(Movie movie, String queueId) async {
    try {
      final docRef = _db.collection('queues').doc(queueId);
      await docRef.update({
        'watched_movies': FieldValue.arrayRemove([movie.toMap()]),
      });
    } catch (e) {
      print('Erro ao remover filme dos assistidos: $e');
      rethrow;
    }
  }

  Future<void> updateUpcomingOrder(List<Movie> movies, String queueId) async {
    try {
      final docRef = _db.collection('queues').doc(queueId);
      final movieMaps = movies.map((m) => m.toMap()).toList();
      await docRef.update({'upcoming_movies': movieMaps});
    } catch (e) {
      print('Erro ao reordenar filmes: $e');
      rethrow;
    }
  }

  Future<void> updateMovieRating(
    Movie movie,
    double rating,
    String queueId,
  ) async {
    final docRef = _db.collection('queues').doc(queueId);
    try {
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> watchedList =
          (data['watched_movies'] as List<dynamic>?) ?? [];
      final newWatchedList = watchedList.map((movieData) {
        final movieFromDb = Movie.fromMap(movieData as Map<String, dynamic>);
        return (movieFromDb.id == movie.id)
            ? movieFromDb.copyWith(rating: rating).toMap()
            : movieData;
      }).toList();
      await docRef.update({'watched_movies': newWatchedList});
    } catch (e) {
      print('Erro ao atualizar o rating do filme: $e');
      rethrow;
    }
  }
}
