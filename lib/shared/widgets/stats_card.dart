// lib/features/social/widgets/stats_card.dart

import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int movieCount;
  // No futuro, podemos adicionar mais estatísticas aqui, como totalHours, etc.

  const StatsCard({super.key, required this.movieCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Stat 1: Filmes Vistos
            _buildStatItem(
              value: movieCount.toString(),
              label: 'Filmes Vistos',
              icon: Icons.theaters,
              color: Colors.orangeAccent,
            ),
            // Adicione mais _buildStatItem aqui no futuro para outras estatísticas
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar cada item de estatística
  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
      ],
    );
  }
}
