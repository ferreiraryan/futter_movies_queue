import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_queue/app/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  String? get currentUserId => _auth.currentUser?.uid;

  // Stream que informa em tempo real se o usuário está logado ou não
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Função de Login
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Aqui você pode tratar erros específicos, como senha errada, etc.
      print("Erro no login: ${e.message}");
      return null;
    }
  }

  // Função de Cadastro
  Future<User?> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Cria o usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // 2. Cria os dados iniciais no Firestore (usuário e primeira fila)
        await _firestoreService.createInitialDataForUser(user, displayName);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Erro no cadastro: ${e.message}");
      return null;
    }
  }

  // Função de Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
