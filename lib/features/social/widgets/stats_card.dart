// lib/features/social/widgets/stats_card.dart

import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int movieCount;
  final int totalMinutes;

  const StatsCard({
    super.key,
    required this.movieCount,
    required this.totalMinutes,
  });

  String _formatDuration(int totalMinutes) {
    if (totalMinutes == 0) return '0h 0m';
    final duration = Duration(minutes: totalMinutes);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              value: movieCount.toString(),
              label: 'Filmes Vistos',
              icon: Icons.theaters,
              color: Colors.orangeAccent,
            ),
            _buildStatItem(
              value: _formatDuration(totalMinutes),
              label: 'Horas Juntos',
              icon: Icons.timer,
              color: Colors.lightBlueAccent,
            ),
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
