// lib/features/social/widgets/scoreboard_card.dart

import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class ScoreboardCard extends StatefulWidget {
  final List<String> memberIds;
  final List<Movie> movies; // Inclui filmes da fila e já assistidos

  const ScoreboardCard({
    super.key,
    required this.memberIds,
    required this.movies,
  });

  @override
  State<ScoreboardCard> createState() => _ScoreboardCardState();
}

class _ScoreboardCardState extends State<ScoreboardCard> {
  // Mapa para guardar as estatísticas calculadas: userId -> contagem
  Map<String, int> _addedByCount = {};
  // Mapa para guardar os nomes dos membros: userId -> displayName
  Map<String, String> _memberNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicia o processamento assim que o widget é criado
    _processStats();
  }

  Future<void> _processStats() async {
    // 1. Calcula a contagem de filmes adicionados por cada usuário
    final counts = <String, int>{};
    for (var movie in widget.movies) {
      if (movie.addedBy != null) {
        counts[movie.addedBy!] = (counts[movie.addedBy] ?? 0) + 1;
      }
    }

    // 2. Busca os nomes de todos os membros de uma vez para ser mais eficiente
    final firestoreService = FirestoreService();
    final userDocs = await Future.wait(
      widget.memberIds.map((id) => firestoreService.getUserDocById(id)),
    );

    final names = <String, String>{};
    for (var doc in userDocs) {
      if (doc.exists) {
        names[doc.id] =
            (doc.data() as Map<String, dynamic>)['displayName'] ?? 'Usuário';
      }
    }

    // 3. Ordena os resultados do maior para o menor
    var sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _addedByCount = Map.fromEntries(sortedEntries);

    // 4. Atualiza o estado do widget com os dados processados
    if (mounted) {
      setState(() {
        _memberNames = names;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placar da Fila',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_addedByCount.isEmpty)
              const Text('Ninguém adicionou filmes ainda.')
            else
              // Cria uma linha para cada membro no placar
              ..._addedByCount.entries.map((entry) {
                final userId = entry.key;
                final count = entry.value;
                final name = _memberNames[userId] ?? 'Desconhecido';

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
