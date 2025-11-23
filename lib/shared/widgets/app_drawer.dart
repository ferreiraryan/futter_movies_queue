import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart';
import 'package:movie_queue/features/movies/screens/movie_list_screen.dart';
import 'package:movie_queue/features/social/screens/social_screen.dart';
import 'package:movie_queue/features/auth/widgets/auth_gate.dart';

class AppDrawer extends StatelessWidget {
  final String queueId;
  const AppDrawer({super.key, required this.queueId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return Drawer(
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            
            stream: firestoreService.getUserDocStream(),
            builder: (context, snapshot) {
              String name = 'Movie Queue';
              String email = 'Bem-vindo!';
              String initial = 'M';

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                name = userData['displayName'] ?? name;
                email = userData['email'] ?? email;
                if (name.isNotEmpty) {
                  initial = name[0].toUpperCase();
                }
              }

              return UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  child: Text(initial, style: const TextStyle(fontSize: 24)),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.movie_filter_outlined),
            title: const Text('Próximos'),
            onTap: () {
              
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
              
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SocialScreenProvider(queueId: queueId),
                ),
              );
            },
          ),

          const Spacer(), 
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              final navigator = Navigator.of(context);
              final authService = AuthService();

              
              await authService.signOut();

              
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthGate()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
