import 'package:flutter/material.dart';
import '../../../shared/widgets/main_background.dart'; // Importa o novo widget
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O código ficou muito mais limpo!
    return const MainBackground(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}
