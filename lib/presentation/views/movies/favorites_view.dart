import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  static const name = 'favorites_view';

  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {
  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNextPage();
  }

  void loadNextPage() async {
    if (isLoading || isLastPage) return;

    isLoading = true;

    final movies = await ref.read(favoritesMoviesProvider.notifier).loadNextPage();

    isLoading = false;

    if (movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final favoritesMovies = ref.watch(favoritesMoviesProvider).values.toList();

    if (favoritesMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 80, color: colors.primary),
            Text('No favorites yet', style: TextStyle(color: colors.primary, fontSize: 25)),
            const Text('Add some movies to your favorites list', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            FilledButton.tonal(onPressed: () => context.go('/home/0'), child: const Text('Discover movies')),
          ],
        ),
      );
    }

    return Scaffold(
      body: MovieMasonry(
        movies: favoritesMovies,
        loadNextPage: loadNextPage,
      ),
    );
  }
}
