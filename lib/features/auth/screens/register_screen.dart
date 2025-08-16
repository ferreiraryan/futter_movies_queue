import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart';
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart'; // Para o enum ScreenType
import 'package:movie_queue/shared/constants/app_colors.dart'; // Supondo que você tenha este arquivo

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores e Chave do Formulário
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Serviços
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Variável de Estado da UI
  bool _isLoading = false;

  // Função principal que orquestra o cadastro
  Future<void> _submitRegisterForm() async {
    // 1. Valida se os campos do formulário foram preenchidos corretamente
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final User? user = await _authService.registerWithUsername(
        username,
        password,
      );

      // 3. SEGUNDO: Verifica se a criação no Auth foi bem-sucedida
      if (user != null) {
        // SUCESSO! Agora cria os documentos no Firestore.
        await _firestoreService.createInitialQueueForUser(user, username);

        // 4. TERCEIRO: Se tudo deu certo, navega para a tela principal
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const QueueLoaderScreen(screenType: ScreenType.upcoming),
            ),
          );
        }
        return;
      } else {
        _showErrorSnackbar("Este nome de usuário já está em uso. Tente outro.");
      }
    } catch (e) {
      // Captura qualquer outro erro inesperado durante o processo
      _showErrorSnackbar("Ocorreu um erro inesperado: ${e.toString()}");
    }

    // Só chega aqui se algo deu errado no meio do caminho
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função auxiliar para mostrar mensagens de erro
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Usando uma cor do seu tema
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Campo de Usuário
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome de usuário.';
                    }
                    if (value.contains(' ')) {
                      return 'O usuário não pode conter espaços.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão de Ação (com feedback de loading)
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitRegisterForm,
                        child: const Text('Cadastrar'),
                      ),

                // Botão para voltar para a tela de login
                TextButton(
                  onPressed: () {
                    // Simplesmente fecha a tela de cadastro para voltar à anterior (Login)
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Já tem uma conta? Faça login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
