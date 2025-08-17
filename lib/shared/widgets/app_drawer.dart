import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart'; // Importe o loader
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart';
import 'package:movie_queue/features/social/screens/social_screen.dart'; // Importe para ter o enum

class AppDrawer extends StatelessWidget {
  final String queueId;
  const AppDrawer({super.key, required this.queueId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Movie Queue"), // TODO: Pegar nome do usuário
            accountEmail: Text(
              "Menu de Navegação",
            ), // TODO: Pegar email do usuário
          ),
          ListTile(
            leading: const Icon(Icons.movie_filter_outlined),
            title: const Text('Próximos'),
            onTap: () {
              // Navega para o loader, que levará para a tela de próximos
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const QueueLoaderScreen(
                    destinationScreenType: ScreenType.upcoming,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Assistidos'),
            onTap: () {
              // Navega para o loader, que levará para a tela de assistidos
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const QueueLoaderScreen(
                    destinationScreenType: ScreenType.watched,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Social'),
            onTap: () {
              // Navega para a nova SocialScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SocialScreen(queueId: queueId),
                ),
              );
            },
          ),

          const Spacer(), // Empurra o botão de sair para o final
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await AuthService().signOut();
              // O AuthGate cuidará de levar para a tela de login
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
