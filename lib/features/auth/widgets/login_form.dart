import 'package:flutter/material.dart';
import '../../../app/services/auth_service.dart'; // Importa nosso serviço
import '../../../shared/widgets/custom_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();
  // Renomeado para refletir que agora é um nome de usuário
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  void _submitForm() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Pega o nome de usuário e a senha
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackbar("Por favor, preencha todos os campos.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // *** A MÁGICA ACONTECE AQUI ***
    // Transforma o nome de usuário em um formato de e-mail falso
    final email = '$username@filaq.app';

    dynamic result;
    if (_isLogin) {
      result = await _authService.signInWithEmailAndPassword(email, password);
    } else {
      result = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
    }

    if (result == null) {
      _showErrorSnackbar(
        "Falha na autenticação. Verifique seu usuário e senha.",
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE6C68A),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de Usuário
          TextFormField(
            controller: _usernameController,
            // Removemos o keyboardType de email
            decoration: InputDecoration(
              labelText: 'Usuário', // Mudamos o texto
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Campo de Senha
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Botão de Ação
          _isLoading
              ? const CircularProgressIndicator()
              : CustomButton(
                  text: _isLogin ? 'Entrar' : 'Cadastrar',
                  onPressed: _submitForm,
                ),
          // Botão para alternar entre Login e Cadastro
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(
              _isLogin
                  ? 'Não tem uma conta? Cadastre-se'
                  : 'Já tem uma conta? Faça login',
              style: const TextStyle(color: Color(0xFF4B3A71)),
            ),
          ),
        ],
      ),
    );
  }
}
