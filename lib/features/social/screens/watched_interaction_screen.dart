import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

class WatchedInteractionScreen extends StatefulWidget {
  final Movie movie;
  final String queueId;

  const WatchedInteractionScreen({
    super.key,
    required this.movie,
    required this.queueId,
  });

  @override
  State<WatchedInteractionScreen> createState() =>
      _WatchedInteractionScreenState();
}

class _WatchedInteractionScreenState extends State<WatchedInteractionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reviewController = TextEditingController();
  bool _isEditingReview = false;

  @override
  void initState() {
    super.initState();
    final currentUserId = AuthService().currentUserId;
    if (currentUserId != null) {
      
      _reviewController.text =
          widget.movie.getReviewForUser(currentUserId) ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;
    final ratingsMap = widget.movie.ratings ?? {};
    final reviewsMap = widget.movie.reviews ?? {};

    
    final Set<String> userIds = {...ratingsMap.keys, ...reviewsMap.keys};
    if (currentUserId != null)
      userIds.add(currentUserId); 

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag:
                        'backdrop-watched-${widget.movie.id}', 
                    child: Image.network(
                      widget.movie.fullBackdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[900]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sua Opinião',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (currentUserId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nota:'),
                              RatingBar.builder(
                                initialRating:
                                    widget.movie.getRatingForUser(
                                      currentUserId,
                                    ) ??
                                    0,
                                minRating: 0.5,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                onRatingUpdate: (rating) {
                                  _firestoreService.updateMovieRating(
                                    widget.movie,
                                    currentUserId,
                                    rating,
                                    widget.queueId,
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Escreva o que achou do filme...',
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _firestoreService.updateMovieReview(
                                  widget.movie,
                                  currentUserId,
                                  _reviewController.text,
                                  widget.queueId,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Resenha salva!'),
                                  ),
                                );
                                FocusScope.of(
                                  context,
                                ).unfocus(); 
                              },
                              child: const Text('Salvar Resenha'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Opiniões do Grupo (${userIds.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final userId = userIds.elementAt(index);
              
              if (userId == currentUserId) return const SizedBox.shrink();

              final rating = ratingsMap[userId] ?? 0.0;
              final review = reviewsMap[userId];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestoreService.getUserDocById(userId),
                builder: (context, snapshot) {
                  String name = 'Carregando...';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['displayName'] ?? 'Anônimo';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(name.isNotEmpty ? name[0] : '?'),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating: rating,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 14.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (review != null && review.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              review,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                              ),
                            ),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Sem resenha escrita.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }, childCount: userIds.length),
          ),

          
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
