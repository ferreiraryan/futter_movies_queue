import 'package:flutter/material.dart';
import 'package:movie_queue/features/auth/screens/queue_loader_screen.dart';
import 'package:movie_queue/shared/constants/app_colors.dart';
import '../../app/services/auth_service.dart';
import '../../features/movies/screens/movie_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _signOut(BuildContext context) async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = AppColors.textPrimary;

    return Drawer(
      backgroundColor: AppColors.formBackground,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 100),
                ListTile(
                  leading: const Icon(
                    Icons.movie_filter_outlined,
                    color: textColor,
                  ),
                  title: const Text(
                    'Próximos',
                    style: TextStyle(color: textColor, fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Fecha o drawer
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QueueLoaderScreen(
                          screenType: ScreenType.upcoming,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: textColor),
                  title: const Text(
                    'Últimos',
                    style: TextStyle(color: textColor, fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QueueLoaderScreen(
                          screenType: ScreenType.watched,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: textColor),
            title: const Text(
              'Sair',
              style: TextStyle(color: textColor, fontSize: 20),
            ),
            onTap: () => _signOut(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
