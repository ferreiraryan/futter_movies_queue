import 'package:flutter/material.dart';

class PersonalityInsightsCard extends StatelessWidget {
  final String enthusiastName;
  final double enthusiastAvg;
  final String criticName;
  final double criticAvg;

  const PersonalityInsightsCard({
    super.key,
    required this.enthusiastName,
    required this.enthusiastAvg,
    required this.criticName,
    required this.criticAvg,
  });

  @override
  Widget build(BuildContext context) {
    
    
    

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900], 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalidades da Fila',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                
                Expanded(
                  child: _buildPersonaColumn(
                    title: '🤩 O Empolgado',
                    name: enthusiastName,
                    avg: enthusiastAvg,
                    color: Colors.greenAccent,
                  ),
                ),
                
                Container(height: 60, width: 1, color: Colors.grey[700]),
                
                Expanded(
                  child: _buildPersonaColumn(
                    title: '🧐 O Crítico',
                    name: criticName,
                    avg: criticAvg,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaColumn({
    required String title,
    required String name,
    required double avg,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Média: ${avg.toStringAsFixed(1)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }
}
