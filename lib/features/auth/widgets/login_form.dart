import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomTextField(label: 'Usuário'),
          const SizedBox(height: 16),
          const CustomTextField(label: 'Senha', isPassword: true),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Entrar',
            onPressed: () {
              // Lógica de login virá aqui
              print('Botão Entrar pressionado!');
            },
          ),
        ],
      ),
    );
  }
}
