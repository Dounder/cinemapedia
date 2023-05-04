import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie_screen';
  final String movieId;

  const MovieScreen({super.key, required this.movieId});

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];

    if (movie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppbar(movie: movie),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 1,
              (context, index) => _MovieDetails(movie: movie),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MoviePoster(movie: movie, size: size, textStyles: textStyles),
              const SizedBox(width: 8),
              SizedBox(
                width: (size.width - 40) * .7,
                child: Column(
                  children: [
                    Text(movie.title, style: textStyles.titleLarge),
                    Text(movie.overview),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map(
                (e) => Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Chip(
                    label: Text(e),
                    backgroundColor: colors.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
        _Actors(movieId: movie.id.toString()),
        const SizedBox(height: 50),
      ],
    );
  }
}

class _Actors extends ConsumerWidget {
  final String movieId;
  const _Actors({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorsByMovies = ref.watch(actorsByMovieProvider);

    if (actorsByMovies[movieId] == null) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: LinearProgressIndicator());
    }

    final actors = actorsByMovies[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: actors.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                FadeIn(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      actor.profilePath,
                      width: 135,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(actor.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  actor.character ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  const _MoviePoster({
    required this.movie,
    required this.size,
    required this.textStyles,
  });

  final Movie movie;
  final Size size;
  final TextTheme textStyles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            movie.posterPath,
            width: size.width * 0.3,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          width: size.width * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: Colors.yellow.shade800),
              const SizedBox(width: 3),
              Text('${movie.voteAverage}', style: textStyles.bodyMedium?.copyWith(color: Colors.yellow.shade800)),
            ],
          ),
        ),
      ],
    );
  }
}

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final repository = ref.watch(localStorageRepositoryProvider);

  return repository.isFavorite(movieId);
});

class _CustomSliverAppbar extends ConsumerWidget {
  final Movie movie;
  const _CustomSliverAppbar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            await ref.read(favoritesMoviesProvider.notifier).toggleFavorite(movie);

            ref.invalidate(isFavoriteProvider(movie.id));
          },
          icon: isFavoriteFuture.when(
            loading: () => const CircularProgressIndicator(),
            data: (isFavorite) => isFavorite
                ? const Icon(Icons.favorite_rounded, color: Colors.red)
                : const Icon(Icons.favorite_border_rounded),
            error: (_, __) => throw Exception('Error'),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();

                  return FadeIn(child: child);
                },
              ),
            ),
            const _CustomGradient(),
            const _CustomGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.2],
              colors: [Colors.black54, Colors.transparent],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final List<double> stops;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  const _CustomGradient({
    this.stops = const [.8, 1],
    this.colors = const [Colors.transparent, Colors.black54],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
