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

  // ... imports e classe ...

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;

    return Scaffold(
      // AppBar transparente para ficar em cima da imagem
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Um ícone de voltar com sombra para garantir leitura
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CABEÇALHO COM HERO ===
            SizedBox(
              height: 300, // Altura da área do banner
              child: Stack(
                children: [
                  // 1. IMAGEM DE FUNDO (BACKDROP)
                  Positioned.fill(
                    child: Hero(
                      // Tag única para o backdrop
                      tag: 'backdrop-${widget.movie.id}',
                      child: Image.network(
                        widget.movie.fullBackdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey[900]),
                      ),
                    ),
                  ),

                  // Gradiente escuro na parte inferior para o texto aparecer
                  Positioned.fill(
                    child: Container(
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
                  ),

                  // 2. PÔSTER FLUTUANTE + TÍTULO
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // O Pôster que "voa" da lista
                        Hero(
                          // Tag única para o pôster
                          tag: 'poster-${widget.movie.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.movie.fullPosterUrl,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Título e Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 10, color: Colors.black),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (widget.movie.genres.isNotEmpty)
                                Text(
                                  widget.movie.genres.take(2).join(', '),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Lançamento: ${widget.movie.releaseDate.split('-')[0]}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // === CORPO DO DETALHE ===
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de Avaliação (mantida igual)
                  if (widget.context == MovieDetailsContext.watched &&
                      currentUserId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sua Avaliação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RatingBar.builder(
                            initialRating:
                                widget.movie.getRatingForUser(currentUserId) ??
                                0,
                            minRating: 0.5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 30,
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
                    ),

                  // Tagline (se existir)
                  if (widget.movie.tagline != null &&
                      widget.movie.tagline!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '"${widget.movie.tagline}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  const Text(
                    'Sinopse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'Sinopse não disponível.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButton(),
    );
  }
}
