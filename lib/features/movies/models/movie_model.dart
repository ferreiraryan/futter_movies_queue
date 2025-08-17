import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final DateTime? watchedAt;
  final double? rating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    this.watchedAt,
    this.rating,
  });

  String get fullPosterUrl {
    if (posterPath.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }

  // --- MÉTODOS PARA O FIRESTORE ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'watchedAt': watchedAt != null ? Timestamp.fromDate(watchedAt!) : null,
      'rating': rating,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['posterPath'] ?? '',
      releaseDate: map['releaseDate'] ?? '',
      watchedAt: (map['watchedAt'] as Timestamp?)?.toDate(),
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }

  // --- MÉTODO PARA A API DO TMDB ---

  // <<< NOVO MÉTODO >>>
  // Cria um objeto Movie a partir de um JSON vindo da API do TMDB
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título não encontrado',
      overview: json['overview'] ?? '',
      // A API usa 'poster_path' com underline
      posterPath: json['poster_path'] ?? '',
      // A API usa 'release_date' com underline
      releaseDate: json['release_date'] ?? '',
      // Esses campos não vêm da API, então são inicializados como nulos
      watchedAt: null,
      rating: null,
    );
  }

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? releaseDate,
    DateTime? watchedAt,
    double? rating,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
    );
  }
}
