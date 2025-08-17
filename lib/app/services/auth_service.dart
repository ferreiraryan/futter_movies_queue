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
  // ... dentro da classe AuthService

  Future<User?> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthService] Tentando criar usuário no Firebase Auth...');
      // 1. Cria o usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        print('[AuthService] Usuário criado no Auth com sucesso: ${user.uid}');
        print('[AuthService] Tentando criar documento no Firestore...');

        // 2. Cria os dados iniciais no Firestore (usuário e primeira fila)
        await _firestoreService.createInitialDataForUser(user, displayName);

        print('[AuthService] Documento no Firestore criado com sucesso!');
      } else {
        print('[AuthService] ERRO: userCredential.user é nulo após a criação.');
      }

      return user;
    } catch (e) {
      // <<< MUDANÇA PRINCIPAL: Captura QUALQUER erro (e não só FirebaseAuthException)
      print('[AuthService] ERRO GERAL NO PROCESSO DE CADASTRO:');
      print(e.toString()); // Imprime o erro exato que está acontecendo
      return null;
    }
  }

  // Função de Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
