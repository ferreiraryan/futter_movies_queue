import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';

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
  bool _isLoading = false;

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
          onPressed: () async {
            setState(() => _isLoading = true);
            await _firestoreService.addMovieToUpcoming(
              widget.movie,
              widget.queueId,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.movie.title} adicionado!')),
            );
            Navigator.of(context).pop();
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
              widget.movie.fullPosterUrl,
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 400,
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.movie, size: 100)),
              ),
            ),

            // Seção de detalhes
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

                  // TODO: Lógica das estrelas de avaliação (rating) virá aqui
                  if (widget.context == MovieDetailsContext.watched)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Estrelas de avaliação aqui...',
                        style: TextStyle(color: Colors.amber),
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
