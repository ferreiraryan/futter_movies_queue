import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/auth_service.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/app/services/tmdb_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Enum para definir o contexto/origem da tela de detalhes
enum MovieDetailsContext { search, upcoming, watched }

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final String queueId;
  final MovieDetailsContext context;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.queueId,
    required this.context,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TmdbService _tmdbService = TmdbService();
  bool _isLoading = false;
  final currentUserId = AuthService().currentUserId;

  // Função que constrói o botão de ação correto baseado no contexto
  Widget? _buildActionButton() {
    // Se estiver carregando, mostra um indicador de progresso
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (widget.context) {
      case MovieDetailsContext.search:
        return _buildButton(
          text: 'Adicionar à Fila',
          color: Colors.white,
          // <<< 3. LÓGICA TOTALMENTE NOVA AQUI >>>
          onPressed: () async {
            setState(() => _isLoading = true);

            try {
              // PASSO 1: Busca os detalhes ricos do filme na API do TMDB
              print('Buscando detalhes para o filme ID: ${widget.movie.id}');
              final enrichedMovie = await _tmdbService.getMovieDetails(
                widget.movie.id,
              );
              print('Detalhes encontrados para: ${enrichedMovie.title}');

              // PASSO 2: Adiciona o filme ENRIQUECIDO ao Firestore
              final resultMessage = await _firestoreService.addMovieToUpcoming(
                enrichedMovie,
                widget.queueId,
              );

              if (!mounted) return;

              final bool success = resultMessage == "Filme adicionado à fila!";

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resultMessage),
                  backgroundColor: success ? Colors.green : Colors.orangeAccent,
                ),
              );

              if (success) {
                Navigator.of(context).pop();
              } else {
                setState(() => _isLoading = false);
              }
            } catch (e) {
              // Se a busca de detalhes falhar, mostra um erro
              if (!mounted) return;
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao buscar detalhes: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      case MovieDetailsContext.upcoming:
        return _buildButton(
          text: 'Marcar como Assistido',
          color: Colors.green,
          onPressed: () async {
            setState(() => _isLoading = true);
            await _firestoreService.moveUpcomingToWatched(
              widget.movie,
              widget.queueId,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.movie.title} marcado como assistido!'),
              ),
            );
            Navigator.of(context).pop();
          },
        );
      case MovieDetailsContext.watched:
        return _buildButton(
          text: 'Remover dos Assistidos',
          color: Colors.redAccent,
          onPressed: () async {
            setState(() => _isLoading = true);
            await _firestoreService.removeMovieFromWatched(
              widget.movie,
              widget.queueId,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.movie.title} removido.')),
            );
            Navigator.of(context).pop();
          },
        );
    }
  }

  // Helper para criar os botões, evitando código repetido
  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Faz o corpo da tela ir por trás da AppBar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pôster do filme
            Image.network(
              widget.movie.fullBackdropUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 250,
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.movie, size: 100)),
              ),
            ), // Seção de detalhes
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lançamento: ${widget.movie.releaseDate}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),

                  if (widget.context == MovieDetailsContext.watched &&
                      currentUserId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sua Avaliação',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RatingBar.builder(
                            initialRating:
                                widget.movie.getRatingForUser(currentUserId!) ??
                                0,
                            minRating: 0.5, // Permite dar meia estrela
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            // 2. Ação de Atualização: Chamado sempre que o usuário toca em uma estrela
                            onRatingUpdate: (rating) {
                              // Chama a função do FirestoreService para salvar a nova nota
                              _firestoreService.updateMovieRating(
                                widget.movie,
                                currentUserId!,
                                rating,
                                widget.queueId,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    'Sinopse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'Sinopse não disponível.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // A barra inferior que contém o botão de ação
      bottomNavigationBar: _buildActionButton(),
    );
  }
}
