// lib/features/social/widgets/scoreboard_card.dart

import 'package:flutter/material.dart';

class ScoreboardCard extends StatelessWidget {
  // Recebe um mapa com o NOME do usuário e a contagem
  final Map<String, int> stats;

  const ScoreboardCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    var sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placar de Filmes Adicionados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              const Text('Ninguém adicionou filmes ainda.')
            else
              ...sortedEntries.map((entry) {
                final name = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(name.isNotEmpty ? name[0] : '?'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '$count filme${count > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
