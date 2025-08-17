// lib/app/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

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

  // --- NOVOS MÉTODOS PARA O SISTEMA DE CONVITES ---

  /// Envia um convite para um usuário se juntar a uma fila.
  Future<void> sendInvite({
    required String inviteeEmail,
    required String queueId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado.");

    // 1. Busca o documento do usuário que está convidando para pegar o nome dele.
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists)
      throw Exception("Documento do usuário não encontrado.");
    final inviterName = userDoc.data()?['displayName'] ?? 'Um amigo';

    // 2. Cria o novo documento de convite na coleção 'invites'.
    await _db.collection('invites').add({
      'inviterId': userId,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail.trim(), // trim() remove espaços extras
      'queueId': queueId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  /// Retorna um stream com todos os convites pendentes para o email do usuário logado.
  Stream<QuerySnapshot> getPendingInvitesForUser() {
    final email = currentUserEmail;
    if (email == null)
      return const Stream.empty(); // Retorna stream vazio se não tiver email

    return _db
        .collection('invites')
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Aceita um convite, movendo o usuário para a nova fila.
  Future<void> acceptInvite(String inviteId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado.");

    final inviteRef = _db.collection('invites').doc(inviteId);

    // Usamos uma transação para garantir que todas as operações ocorram juntas.
    await _db.runTransaction((transaction) async {
      // 1. Pega os dados do convite.
      final inviteDoc = await transaction.get(inviteRef);
      if (!inviteDoc.exists) throw Exception("Convite não encontrado.");

      final queueId = inviteDoc.data()!['queueId'];
      final queueRef = _db.collection('queues').doc(queueId);
      final userRef = _db.collection('users').doc(userId);

      // 2. Atualiza o status do convite para "accepted".
      transaction.update(inviteRef, {'status': 'accepted'});

      // 3. Adiciona o usuário à lista de membros da nova fila.
      transaction.update(queueRef, {
        'members': FieldValue.arrayUnion([userId]),
      });

      // 4. Atualiza a fila ativa do usuário para a nova fila.
      transaction.update(userRef, {'activeQueueId': queueId});
    });
  }

  /// Recusa um convite, apenas mudando seu status.
  Future<void> declineInvite(String inviteId) async {
    await _db.collection('invites').doc(inviteId).update({
      'status': 'declined',
    });
  }
}
