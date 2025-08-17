import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final DateTime? watchedAt;
  final Map<String, double>? ratings;

  // <<< NOVOS CAMPOS >>>
  final int? runtime; // Duração em minutos
  final List<String> genres; // Lista de nomes dos gêneros
  final String? backdropPath; // Imagem de fundo
  final double? tmdbRating; // Nota média do TMDB
  final String? tagline; // Slogan do filme
  final String? addedBy;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    this.watchedAt,
    this.ratings,
    // <<< NOVOS CAMPOS NO CONSTRUTOR >>>
    this.runtime,
    this.genres = const [], // Garante que a lista nunca seja nula
    this.backdropPath,
    this.tmdbRating,
    this.tagline,
    this.addedBy,
  });

  String get fullPosterUrl {
    if (posterPath.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  // <<< NOVO GETTER PARA A IMAGEM DE FUNDO >>>
  String get fullBackdropUrl {
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    // Se não tiver imagem de fundo, usa o pôster como fallback
    return fullPosterUrl;
  }

  double? getRatingForUser(String userId) {
    return ratings?[userId];
  }

  // <<< toMap ATUALIZADO >>>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'watchedAt': watchedAt != null ? Timestamp.fromDate(watchedAt!) : null,
      'ratings': ratings,
      'runtime': runtime,
      'genres': genres,
      'backdropPath': backdropPath,
      'tmdbRating': tmdbRating,
      'tagline': tagline,
      'addedBy': addedBy,
    };
  }

  // <<< fromMap ATUALIZADO >>>
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['posterPath'] ?? '',
      releaseDate: map['releaseDate'] ?? '',
      watchedAt: (map['watchedAt'] as Timestamp?)?.toDate(),
      ratings: map['ratings'] != null
          ? Map<String, double>.from(map['ratings'])
          : null,
      // Usamos '??' para garantir que o app não quebre ao ler dados antigos do Firestore
      runtime: map['runtime'],
      genres: List<String>.from(map['genres'] ?? []),
      backdropPath: map['backdropPath'],
      tmdbRating: (map['tmdbRating'] as num?)?.toDouble(),
      tagline: map['tagline'],
      addedBy: map['addedBy'],
    );
  }

  // <<< fromJson (da busca) continua igual, pois a busca não traz esses dados >>>
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título não encontrado',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
    );
  }

  // <<< copyWith ATUALIZADO >>>
  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? releaseDate,
    DateTime? watchedAt,
    Map<String, double>? ratings,
    int? runtime,
    List<String>? genres,
    String? backdropPath,
    double? tmdbRating,
    String? tagline,
    String? addedBy,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      watchedAt: watchedAt ?? this.watchedAt,
      ratings: ratings ?? this.ratings,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      backdropPath: backdropPath ?? this.backdropPath,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      tagline: tagline ?? this.tagline,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
