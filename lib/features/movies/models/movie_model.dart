import 'dart:ffi';

import 'package:flutter/foundation.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String releaseDate;
  final double? rating;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.releaseDate,
    this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: json['id'],
    title: json['title'],
    posterPath: json['poster_path'],
    overview: json['overview'] ?? 'Sinopse não disponível.',
    releaseDate: json['release_date'] ?? 'Data não informada.',
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'poster_path': posterPath,
    'overview': overview,
    'release_date': releaseDate,
    'rating': rating,
  };
  factory Movie.fromMap(Map<String, dynamic> map) {
    final num? ratingValue = map['rating'];

    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['poster_path'],
      overview: map['overview'],
      releaseDate: map['release_date'],
      rating: ratingValue?.toDouble(),
    );
  }
  String get fullPosterUrl => (posterPath != null && posterPath!.isNotEmpty)
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://placehold.co/500x750/4B3A71/FFFFFF?text=Sem+Imagem';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
