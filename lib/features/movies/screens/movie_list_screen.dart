import 'dart:async';
import 'dart:math'; // <<< IMPORT NECESSÁRIO PARA A ROLETA
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';
import 'package:movie_queue/features/movies/models/movie_model.dart';
import 'package:movie_queue/features/movies/screens/movie_details_screen.dart';
import 'package:movie_queue/features/movies/screens/movie_search_screen.dart';
import 'package:movie_queue/features/movies/widgets/featured_movie_card.dart';
import 'package:movie_queue/features/movies/widgets/movie_skeleton_loader.dart';
import 'package:movie_queue/features/movies/widgets/upcoming_movie_card.dart';
import 'package:movie_queue/features/movies/widgets/watched_movie_card.dart';
import 'package:movie_queue/features/social/screens/watched_interaction_screen.dart';
import 'package:movie_queue/shared/widgets/app_drawer.dart';

enum ScreenType { upcoming, watched }

class MovieListScreen extends StatefulWidget {
  // ... (construtor sem alterações)
  final String queueId;
  final ScreenType screenType;

  const MovieListScreen({
    super.key,
    required this.queueId,
    required this.screenType,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // ... (variáveis de estado, initState, _listenToMovieChanges, dispose, _onReorder mantidos iguais)
  final FirestoreService _firestoreService = FirestoreService();
  late StreamSubscription<DocumentSnapshot> _movieSubscription;
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _selectedGenre;
  String? _selectedDuration;
  Set<String> _availableGenres = {};

  @override
  void initState() {
    super.initState();
    _listenToMovieChanges();
  }

  // ... (_listenToMovieChanges e dispose iguais)
  void _listenToMovieChanges() {
    final String listKey = widget.screenType == ScreenType.upcoming
        ? 'upcoming_movies'
        : 'watched_movies';

    _movieSubscription = _firestoreService
        .getQueueStream(widget.queueId)
        .listen((snapshot) {
          if (!mounted) return;

          List<Movie> newMovies = [];
          Set<String> genres = {};

          if (snapshot.exists && snapshot.data() != null) {
            final queueData = snapshot.data() as Map<String, dynamic>;
            final movieDataList = (queueData[listKey] as List<dynamic>?) ?? [];
            newMovies = movieDataList
                .map((data) => Movie.fromMap(data))
                .toList();

            for (var movie in newMovies) {
              genres.addAll(movie.genres);
            }
          }

          setState(() {
            _movies = newMovies;
            _availableGenres = genres;
            _isLoading = false;
          });
        });
  }

  @override
  void dispose() {
    _movieSubscription.cancel();
    super.dispose();
  }

  // ... (_onReorder e _getFilteredMovies iguais)
  void _onReorder(int oldIndex, int newIndex) {
    if (_selectedGenre != null || _selectedDuration != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Limpe os filtros para reordenar.")),
      );
      return;
    }

    // Lógica padrão do Flutter para reordenação
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      // Agora removemos e inserimos diretamente, pois o Banner (índice 0)
      // faz parte da lista manipulável.
      final Movie item = _movies.removeAt(oldIndex);
      _movies.insert(newIndex, item);
    });

    _firestoreService.updateUpcomingOrder(_movies, widget.queueId);
  }

  List<Movie> _getFilteredMovies() {
    return _movies.where((movie) {
      if (_selectedGenre != null && !movie.genres.contains(_selectedGenre)) {
        return false;
      }
      if (_selectedDuration != null) {
        final runtime = movie.runtime ?? 0;
        if (_selectedDuration == 'Curto (< 90m)' && runtime >= 90) return false;
        if (_selectedDuration == 'Médio (90m-2h30)' &&
            (runtime < 90 || runtime > 150))
          return false;
        if (_selectedDuration == 'Longo (> 2h30)' && runtime <= 150)
          return false;
      }
      return true;
    }).toList();
  }

  // <<< NOVO: Lógica da Roleta >>>
  void _pickRandomMovie() {
    // 1. Usa a lista FILTRADA (respeita as escolhas do usuário)
    final candidates = _getFilteredMovies();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhum filme disponível para sortear!")),
      );
      return;
    }

    // 2. Sorteia um índice aleatório
    final random = Random();
    final winnerIndex = random.nextInt(candidates.length);
    final winner = candidates[winnerIndex];

    // 3. Mostra o vencedor em um Dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "🍿 O escolhido foi...",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exibe o pôster do vencedor
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  winner.fullPosterUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                winner.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                winner.tagline ?? "Prepare a pipoca!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickRandomMovie(); // Gira de novo!
              },
              child: const Text("Girar de novo"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(context);
                // Abre os detalhes para ver mais ou marcar como assistido
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(
                      movie: winner,
                      queueId: widget.queueId,
                      context: MovieDetailsContext.upcoming,
                    ),
                  ),
                );
              },
              child: const Text("Ver Detalhes"),
            ),
          ],
        );
      },
    );
  }

  // ... (_buildFilters e _showDurationPicker mantidos iguais)
  Widget _buildFilters() {
    if (_movies.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_selectedGenre != null || _selectedDuration != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _selectedGenre = null;
                  _selectedDuration = null;
                }),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(_selectedDuration ?? 'Duração'),
              selected: _selectedDuration != null,
              onSelected: (bool selected) {
                _showDurationPicker();
              },
            ),
          ),
          ..._availableGenres.map((genre) {
            final isSelected = _selectedGenre == genre;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedGenre = selected ? genre : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Qualquer Duração'),
              onTap: () {
                setState(() => _selectedDuration = null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Curto (< 90m)'),
              onTap: () {
                setState(() => _selectedDuration = 'Curto (< 90m)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Médio (90m-2h30)'),
              onTap: () {
                setState(() => _selectedDuration = 'Médio (90m-2h30)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Longo (> 2h30)'),
              onTap: () {
                setState(() => _selectedDuration = 'Longo (> 2h30)');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.screenType == ScreenType.upcoming
        ? 'Próximos Filmes'
        : 'Filmes Assistidos';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // <<< NOVO: Botão da Roleta na AppBar >>>
        actions: [
          if (widget.screenType == ScreenType.upcoming && _movies.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.casino), // Ícone de dado
              tooltip: 'Escolher Aleatoriamente',
              onPressed: _pickRandomMovie,
            ),
        ],
      ),
      drawer: AppDrawer(queueId: widget.queueId),
      body: Column(
        children: [
          if (widget.screenType == ScreenType.upcoming) _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieSearchScreen(queueId: widget.queueId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ... (código anterior igual)

  Widget _buildBody() {
    if (_isLoading) {
      return const MovieSkeletonLoader();
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'Nenhum filme nesta lista ainda.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
    }

    // Filtros
    final filteredMovies = _getFilteredMovies();
    bool hasFilters = _selectedGenre != null || _selectedDuration != null;

    if (hasFilters || filteredMovies.isEmpty) {
      if (filteredMovies.isEmpty)
        return const Center(child: Text("Nenhum filme encontrado."));

      return ListView.builder(
        itemCount: filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = filteredMovies[index];
          return UpcomingMovieCard(
            key: ValueKey(movie.id),
            movie: movie,
            index: index,
            onTap: () => _navigateToDetails(movie),
          );
        },
      );
    }

    if (widget.screenType == ScreenType.watched) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = filteredMovies[index];
          return Dismissible(
            key: Key(movie.id.toString()),
            direction: DismissDirection.endToStart,
            background: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.redAccent,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Icon(Icons.delete, color: Colors.white)],
                ),
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirmar Exclusão"),
                    content: Text(
                      "Tem certeza que deseja remover '${movie.title}' da sua lista de assistidos?",
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          _firestoreService.removeMovieFromWatched(
                            movie,
                            widget.queueId,
                          );
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("Remover"),
                      ),
                    ],
                  );
                },
              );
            },
            child: WatchedMovieCard(
              movie: movie,
              queueId: widget.queueId,
              onTap: () {
                // <<< NAVEGAÇÃO PARA A NOVA TELA DE INTERAÇÃO >>>
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WatchedInteractionScreen(
                      movie: movie,
                      queueId: widget.queueId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    // === LAYOUT UNIFICADO CORRIGIDO ===
    return CustomScrollView(
      slivers: [
        SliverReorderableList(
          itemCount: _movies.length,
          onReorder: _onReorder,

          // PROXY DECORATOR: AQUI ESTÁ A CORREÇÃO VISUAL
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue = Curves.easeInOut.transform(
                  animation.value,
                );
                final double elevation = lerpDouble(0, 6, animValue)!;

                // Se arrastar o BANNER (0) ou o PRIMEIRO DA LISTA (1)
                // Nós forçamos a renderização de um 'UpcomingMovieCard' LIMPO.
                // Isso remove o título "Próximos na Fila" do item 1 enquanto ele voa.
                if (index == 0 || index == 1) {
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    child: UpcomingMovieCard(
                      movie: _movies[index],
                      index: index,
                      onTap: () {},
                    ),
                  );
                }

                return Material(
                  elevation: elevation,
                  color: Colors.transparent,
                  child: child,
                );
              },
              child: child,
            );
          },

          itemBuilder: (context, index) {
            final movie = _movies[index];

            // CASO 1: BANNER
            if (index == 0) {
              return ReorderableDelayedDragStartListener(
                key: ValueKey(movie.id),
                index: index,
                child: FeaturedMovieCard(
                  movie: movie,
                  onTap: () => _navigateToDetails(movie),
                  onMarkAsWatched: () {
                    _firestoreService.moveUpcomingToWatched(
                      movie,
                      widget.queueId,
                    );
                  },
                ),
              );
            }

            // CASO 2: LISTA COMUM
            return Column(
              key: ValueKey(movie.id),
              children: [
                if (index == 1 && _movies.length > 1)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      24.0,
                      16.0,
                      8.0,
                    ), // Aumentei o topo para 24.0
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Próximos na Fila',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                UpcomingMovieCard(
                  movie: movie,
                  index: index,
                  onTap: () => _navigateToDetails(movie),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Helper para limpar o código repetido de navegação
  void _navigateToDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(
          movie: movie,
          queueId: widget.queueId,
          context: MovieDetailsContext.upcoming,
        ),
      ),
    );
  }
}
