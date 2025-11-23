import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieSkeletonLoader extends StatelessWidget {
  const MovieSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // O Shimmer envolve o conteúdo que vai "brilhar"
    return Shimmer.fromColors(
      // Cores para o tema escuro (cinza escuro -> cinza um pouco mais claro)
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 6, // Desenha 6 itens falsos para encher a tela
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          // O primeiro item finge ser o Banner Gigante
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      Colors.white, // A cor aqui não importa, o Shimmer cobre
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }

          // Os outros itens fingem ser os cards da lista
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                // Pôster falso
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                // Textos falsos (Título e Ano)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
