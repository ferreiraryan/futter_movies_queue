

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/movies/models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  Future<void> updateMovieReview(
    Movie movieToUpdate,
    String userId,
    String newReview,
    String queueId,
  ) async {
    final docRef = _db.collection('queues').doc(queueId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final List<dynamic> watchedListRaw =
        (doc.data()! as Map<String, dynamic>)['watched_movies'] ?? [];
    List<Movie> watchedList = watchedListRaw
        .map((data) => Movie.fromMap(data))
        .toList();

    final int movieIndex = watchedList.indexWhere(
      (m) => m.id == movieToUpdate.id,
    );

    if (movieIndex != -1) {
      final Movie oldMovie = watchedList[movieIndex];

      
      final Map<String, String> updatedReviews = Map.from(
        oldMovie.reviews ?? {},
      );
      updatedReviews[userId] = newReview;

      final Movie updatedMovie = oldMovie.copyWith(reviews: updatedReviews);
      watchedList[movieIndex] = updatedMovie;

      final List<Map<String, dynamic>> finalMovieMaps = watchedList
          .map((m) => m.toMap())
          .toList();
      await docRef.update({'watched_movies': finalMovieMaps});
    }
  }

  Future<void> updateQueueGoal(
    String queueId,
    int newGoal,
    DateTime? endDate,
  ) async {
    await _db.collection('queues').doc(queueId).update({
      'goal': newGoal,
      'goalEndDate': endDate != null ? Timestamp.fromDate(endDate) : null,
    });
  }

  Stream<DocumentSnapshot> getUserDocStream() {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado");
    return _db.collection('users').doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> getQueueStream(String queueId) {
    return _db.collection('queues').doc(queueId).snapshots();
  }

  Future<void> createInitialDataForUser(User user, String displayName) async {
    print(
      '[FirestoreService] Iniciando a criação de dados iniciais para ${user.uid}',
    );

    
    final batch = _db.batch();

    
    final newQueueRef = _db.collection('queues').doc();
    batch.set(newQueueRef, {
      'ownerId': user.uid,
      'members': [user.uid],
      'upcoming_movies': [],
      'watched_movies': [],
    });
    print('[FirestoreService] Operação de criar FILA adicionada ao batch.');

    
    final userDocRef = _db.collection('users').doc(user.uid);
    batch.set(userDocRef, {
      'displayName': displayName,
      'email': user.email,
      'activeQueueId': newQueueRef.id,
    });
    print('[FirestoreService] Operação de criar USUÁRIO adicionada ao batch.');

    try {
      
      print('[FirestoreService] Executando o batch...');
      await batch.commit();
      print(
        '[FirestoreService] Batch executado com sucesso! Usuário e Fila criados.',
      );
    } catch (e) {
      print('[FirestoreService] ERRO CRÍTICO ao executar o batch:');
      print(e.toString());
      throw e;
    }
  }

  
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

      
      updatedRatings[userId] = newRating;

      
      final Movie updatedMovie = oldMovie.copyWith(ratings: updatedRatings);

      
      watchedList[movieIndex] = updatedMovie;

      
      final List<Map<String, dynamic>> finalMovieMaps = watchedList
          .map((m) => m.toMap())
          .toList();
      await docRef.update({'watched_movies': finalMovieMaps});
    }
  }

  Future<String> addMovieToUpcoming(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);

    
    final doc = await docRef.get();
    if (!doc.exists) return "Erro: Fila não encontrada.";
    final data = doc.data()! as Map<String, dynamic>;
    final List<dynamic> upcomingRaw = data['upcoming_movies'] ?? [];
    final List<dynamic> watchedRaw = data['watched_movies'] ?? [];
    if (upcomingRaw.any((m) => m['id'] == movie.id)) {
      return "Este filme já está na sua fila.";
    }
    if (watchedRaw.any((m) => m['id'] == movie.id)) {
      return "Você já assistiu a este filme.";
    }

    
    
    final userId = currentUserId;
    if (userId == null) return "Erro: Usuário não identificado.";

    
    final movieWithUser = movie.copyWith(addedBy: userId);

    
    await docRef.update({
      'upcoming_movies': FieldValue.arrayUnion([movieWithUser.toMap()]),
    });

    return "Filme adicionado à fila!";
  }

  Future<void> moveUpcomingToWatched(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()! as Map<String, dynamic>;

    
    final List<dynamic> upcomingRaw = data['upcoming_movies'] ?? [];
    List<Map<String, dynamic>> updatedUpcomingList = List.from(upcomingRaw);
    updatedUpcomingList.removeWhere((m) => m['id'] == movie.id);

    
    final List<dynamic> watchedRaw = data['watched_movies'] ?? [];
    List<Map<String, dynamic>> updatedWatchedList = List.from(watchedRaw);
    final watchedMovie = movie.copyWith(watchedAt: DateTime.now());
    
    if (!updatedWatchedList.any((m) => m['id'] == watchedMovie.id)) {
      updatedWatchedList.add(watchedMovie.toMap());
    }

    
    await docRef.update({
      'upcoming_movies': updatedUpcomingList,
      'watched_movies': updatedWatchedList,
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

  Future<void> removeMovieFromWatched(
    Movie movieToRemove,
    String queueId,
  ) async {
    final docRef = _db.collection('queues').doc(queueId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()! as Map<String, dynamic>;

    
    final List<dynamic> watchedListRaw = data['watched_movies'] ?? [];
    List<Map<String, dynamic>> updatedWatchedList = List.from(watchedListRaw);

    
    updatedWatchedList.removeWhere((m) => m['id'] == movieToRemove.id);

    
    await docRef.update({'watched_movies': updatedWatchedList});
  }

  

  
  Future<void> sendInvite({
    required String inviteeEmail,
    required String queueId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado.");

    
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception("Documento do usuário não encontrado.");
    }
    final inviterName = userDoc.data()?['displayName'] ?? 'Um amigo';

    
    await _db.collection('invites').add({
      'inviterId': userId,
      'inviterName': inviterName,
      'inviteeEmail': inviteeEmail.trim(), 
      'queueId': queueId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  
  Stream<QuerySnapshot> getPendingInvitesForUser() {
    final email = currentUserEmail;
    if (email == null) {
      return const Stream.empty(); 
    }

    return _db
        .collection('invites')
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  
  

  Future<void> acceptInvite(String inviteId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado.");

    final inviteRef = _db.collection('invites').doc(inviteId);

    await _db.runTransaction((transaction) async {
      
      final inviteDoc = await transaction.get(inviteRef);
      if (!inviteDoc.exists) throw Exception("Convite não encontrado.");

      final newQueueId = inviteDoc.data()!['queueId'];
      final userRef = _db.collection('users').doc(userId);

      
      
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception("Usuário que está aceitando não foi encontrado.");
      }
      final oldQueueId = userDoc.data()?['activeQueueId'];

      
      transaction.update(inviteRef, {'status': 'accepted'});

      
      final newQueueRef = _db.collection('queues').doc(newQueueId);
      transaction.update(newQueueRef, {
        'members': FieldValue.arrayUnion([userId]),
      });

      
      transaction.update(userRef, {'activeQueueId': newQueueId});

      
      
      if (oldQueueId != null && oldQueueId != newQueueId) {
        final oldQueueRef = _db.collection('queues').doc(oldQueueId);
        transaction.update(oldQueueRef, {
          'members': FieldValue.arrayRemove([userId]),
        });
      }
    });
  }

  
  Future<void> declineInvite(String inviteId) async {
    await _db.collection('invites').doc(inviteId).update({
      'status': 'declined',
    });
  }

  Future<DocumentSnapshot> getUserDocById(String userId) {
    return _db.collection('users').doc(userId).get();
  }
}
