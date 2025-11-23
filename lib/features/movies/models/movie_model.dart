import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final DateTime? watchedAt;
  final Map<String, double>? ratings;

  final Map<String, String>? reviews;

  final int? runtime;
  final List<String> genres;
  final String? backdropPath;
  final double? tmdbRating;
  final String? tagline;
  final String? addedBy;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    this.watchedAt,
    this.ratings,

    this.reviews,
    this.runtime,
    this.genres = const [],
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

  String get fullBackdropUrl {
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    return fullPosterUrl;
  }

  double? getRatingForUser(String userId) {
    return ratings?[userId];
  }

  String? getReviewForUser(String userId) {
    return reviews?[userId];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'watchedAt': watchedAt != null ? Timestamp.fromDate(watchedAt!) : null,
      'ratings': ratings,
      'reviews': reviews,
      'runtime': runtime,
      'genres': genres,
      'backdropPath': backdropPath,
      'tmdbRating': tmdbRating,
      'tagline': tagline,
      'addedBy': addedBy,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['posterPath'] ?? '',
      releaseDate: map['release_date'] ?? map['releaseDate'] ?? '',
      watchedAt: (map['watchedAt'] as Timestamp?)?.toDate(),

      ratings: map['ratings'] != null
          ? (map['ratings'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            )
          : null,

      reviews: map['reviews'] != null
          ? Map<String, String>.from(map['reviews'])
          : null,

      runtime: map['runtime'],
      genres: List<String>.from(map['genres'] ?? []),
      backdropPath: map['backdropPath'],
      tmdbRating: (map['tmdbRating'] as num?)?.toDouble(),
      tagline: map['tagline'],
      addedBy: map['addedBy'],
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título não encontrado',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      watchedAt: null,
      ratings: null,
      reviews: null,
    );
  }

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? releaseDate,
    DateTime? watchedAt,
    Map<String, double>? ratings,
    Map<String, String>? reviews,
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
      reviews: reviews ?? this.reviews,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      backdropPath: backdropPath ?? this.backdropPath,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      tagline: tagline ?? this.tagline,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
