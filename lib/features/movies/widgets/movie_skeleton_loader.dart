import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieSkeletonLoader extends StatelessWidget {
  const MovieSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Shimmer.fromColors(
      
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView.builder(
        itemCount: 6, 
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      Colors.white, 
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }

          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                
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
