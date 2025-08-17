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
    print(
      '[FirestoreService] Iniciando a criação de dados iniciais para ${user.uid}',
    );

    // Cria um "batch" - um pacote de operações de escrita
    final batch = _db.batch();

    // Define a referência para a nova fila (sem criar ainda)
    final newQueueRef = _db.collection('queues').doc();
    batch.set(newQueueRef, {
      'ownerId': user.uid,
      'members': [user.uid],
      'upcoming_movies': [],
      'watched_movies': [],
    });
    print('[FirestoreService] Operação de criar FILA adicionada ao batch.');

    // Define a referência para o novo usuário (sem criar ainda)
    final userDocRef = _db.collection('users').doc(user.uid);
    batch.set(userDocRef, {
      'displayName': displayName,
      'email': user.email,
      'activeQueueId': newQueueRef.id,
    });
    print('[FirestoreService] Operação de criar USUÁRIO adicionada ao batch.');

    try {
      // Commita o batch: envia todas as operações para o Firebase de uma vez só
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

  Future<String> addMovieToUpcoming(Movie movie, String queueId) async {
    final docRef = _db.collection('queues').doc(queueId);

    // ... (lógica de checagem para ver se o filme já existe, sem alterações)
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

    // <<< MUDANÇA PRINCIPAL AQUI >>>
    // Pega o ID do usuário logado
    final userId = currentUserId;
    if (userId == null) return "Erro: Usuário não identificado.";

    // Cria uma cópia do filme e carimba com o ID do usuário
    final movieWithUser = movie.copyWith(addedBy: userId);

    // Salva a versão carimbada do filme
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

    // 1. Pega a lista de "próximos" e remove o filme pelo ID
    final List<dynamic> upcomingRaw = data['upcoming_movies'] ?? [];
    List<Map<String, dynamic>> updatedUpcomingList = List.from(upcomingRaw);
    updatedUpcomingList.removeWhere((m) => m['id'] == movie.id);

    // 2. Pega a lista de "assistidos" e adiciona a nova versão do filme com a data
    final List<dynamic> watchedRaw = data['watched_movies'] ?? [];
    List<Map<String, dynamic>> updatedWatchedList = List.from(watchedRaw);
    final watchedMovie = movie.copyWith(watchedAt: DateTime.now());
    // Evita adicionar duplicado caso haja algum clique duplo rápido
    if (!updatedWatchedList.any((m) => m['id'] == watchedMovie.id)) {
      updatedWatchedList.add(watchedMovie.toMap());
    }

    // 3. Salva as duas listas atualizadas de volta no Firestore
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

    // 1. Pega a lista de "assistidos"
    final List<dynamic> watchedListRaw = data['watched_movies'] ?? [];
    List<Map<String, dynamic>> updatedWatchedList = List.from(watchedListRaw);

    // 2. Remove o filme da lista pelo seu ID único
    updatedWatchedList.removeWhere((m) => m['id'] == movieToRemove.id);

    // 3. Salva a lista atualizada de volta no Firestore
    await docRef.update({'watched_movies': updatedWatchedList});
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
    if (!userDoc.exists) {
      throw Exception("Documento do usuário não encontrado.");
    }
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
    if (email == null) {
      return const Stream.empty(); // Retorna stream vazio se não tiver email
    }

    return _db
        .collection('invites')
        .where('inviteeEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Aceita um convite, movendo o usuário para a nova fila.
  // ... dentro da classe FirestoreService

  Future<void> acceptInvite(String inviteId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("Usuário não autenticado.");

    final inviteRef = _db.collection('invites').doc(inviteId);

    await _db.runTransaction((transaction) async {
      // 1. Pega os dados do convite.
      final inviteDoc = await transaction.get(inviteRef);
      if (!inviteDoc.exists) throw Exception("Convite não encontrado.");

      final newQueueId = inviteDoc.data()!['queueId'];
      final userRef = _db.collection('users').doc(userId);

      // <<< PASSO NOVO: LER A FILA ANTIGA ANTES DE MUDAR >>>
      // Para saber de qual fila remover o usuário, primeiro lemos o documento dele.
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception("Usuário que está aceitando não foi encontrado.");
      }
      final oldQueueId = userDoc.data()?['activeQueueId'];

      // 2. Atualiza o status do convite para "accepted".
      transaction.update(inviteRef, {'status': 'accepted'});

      // 3. Adiciona o usuário à lista de membros da NOVA fila.
      final newQueueRef = _db.collection('queues').doc(newQueueId);
      transaction.update(newQueueRef, {
        'members': FieldValue.arrayUnion([userId]),
      });

      // 4. Atualiza a fila ativa do usuário para a NOVA fila.
      transaction.update(userRef, {'activeQueueId': newQueueId});

      // <<< PASSO NOVO: REMOVER O USUÁRIO DA FILA ANTIGA >>>
      // Se o usuário tinha uma fila antiga e ela é diferente da nova, removemos ele de lá.
      if (oldQueueId != null && oldQueueId != newQueueId) {
        final oldQueueRef = _db.collection('queues').doc(oldQueueId);
        transaction.update(oldQueueRef, {
          'members': FieldValue.arrayRemove([userId]),
        });
      }
    });
  }

  /// Recusa um convite, apenas mudando seu status.
  Future<void> declineInvite(String inviteId) async {
    await _db.collection('invites').doc(inviteId).update({
      'status': 'declined',
    });
  }

  Future<DocumentSnapshot> getUserDocById(String userId) {
    return _db.collection('users').doc(userId).get();
  }
}
