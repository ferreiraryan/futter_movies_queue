import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final int watchedCount;
  final int goal;
  final DateTime? endDate; // Data limite
  final VoidCallback? onEdit;

  const GoalCard({
    super.key,
    required this.watchedCount,
    required this.goal,
    this.endDate,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (goal > 0)
        ? (watchedCount / goal).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = (progress * 100).toInt();

    // Verifica os estados da meta
    final bool isCompleted = watchedCount >= goal;
    final bool isExpired =
        endDate != null && DateTime.now().isAfter(endDate!) && !isCompleted;

    // Cores e Textos dinâmicos baseados no estado
    List<Color> gradientColors;
    String statusText;
    IconData statusIcon;

    if (isCompleted) {
      // Sucesso: Verde/Dourado
      gradientColors = [Colors.green.shade800, Colors.green.shade600];
      statusText = 'Meta Conquistada! 🎉';
      statusIcon = Icons.emoji_events;
    } else if (isExpired) {
      // Falha: Cinza/Vermelho
      gradientColors = [Colors.grey.shade800, Colors.grey.shade700];
      statusText = 'O tempo acabou. Tente uma nova meta!';
      statusIcon = Icons.timer_off;
    } else {
      // Em andamento: Roxo padrão
      gradientColors = [Colors.deepPurple.shade900, Colors.deepPurple.shade700];
      statusText = 'Faltam ${goal - watchedCount} filmes';
      if (endDate != null) {
        final daysLeft = endDate!.difference(DateTime.now()).inDays;
        statusText += ' • $daysLeft dias restantes';
      }
      statusIcon = Icons.flag;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   gradient: LinearGradient(
      //     colors: gradientColors,
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Desafio da Maratona',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Se completou ou expirou, mostra botão para definir NOVA meta
                if (isCompleted || isExpired)
                  ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Nova Meta'),
                  )
                else if (onEdit != null)
                  // Se está em andamento, mostra botão de editar discreto
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.purpleAccent.shade100),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
                else
                  Icon(statusIcon, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.black26,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.white : Colors.purpleAccent,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$watchedCount / $goal filmes',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            if (endDate != null && !isCompleted && !isExpired)
              Text(
                'Prazo: ${DateFormat('dd/MM/yyyy').format(endDate!)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
