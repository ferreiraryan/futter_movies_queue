import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/social/widgets/user_rating_row.dart';

class RatingBreakdownDialog extends StatelessWidget {
  final Movie movie;
  final String queueId;

  const RatingBreakdownDialog({
    super.key,
    required this.movie,
    required this.queueId,
  });

  @override
  Widget build(BuildContext context) {
    final ratingsMap = movie.ratings ?? {};
    final currentUserId = AuthService().currentUserId;

    
    final List<String> userIdsToDisplay = ratingsMap.keys.toList();

    
    if (currentUserId != null && !userIdsToDisplay.contains(currentUserId)) {
      userIdsToDisplay.add(currentUserId);
    }

    return AlertDialog(
      title: Text('Notas para "${movie.title}"'),
      content: SizedBox(
        width: double.maxFinite,
        
        child: userIdsToDisplay.isEmpty
            ? const Text('Não foi possível identificar o usuário para avaliar.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: userIdsToDisplay.length,
                itemBuilder: (context, index) {
                  final userId = userIdsToDisplay[index];
                  
                  final rating = ratingsMap[userId] ?? 0.0;

                  return UserRatingRow(
                    userId: userId,
                    rating: rating,
                    movie: movie,
                    queueId: queueId,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
