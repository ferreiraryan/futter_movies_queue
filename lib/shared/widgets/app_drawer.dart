import 'package:flutter/material.dart';
import '../../app/services/auth_service.dart'; // Importa o serviço
import '../../features/movies/screens/movie_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _signOut(BuildContext context) async {
    await AuthService().signOut();
    // O AuthGate cuidará de redirecionar para a tela de login.
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF3A86FF),
      child: Column(
        children: <Widget>[
          const Expanded(
            child: Column(
              children: [
                SizedBox(height: 100),
                // ... Seus outros ListTiles (Próximos, Últimos) ...
              ],
            ),
          ),
          // Botão de Sair no final
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onTap: () => _signOut(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

