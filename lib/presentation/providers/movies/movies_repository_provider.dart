import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';

// Inmutable provider for MovieRepository implementation
final movieRepositoryProvider = Provider((ref) => MovieRepositoryImpl(MovieDbDataSource()));
