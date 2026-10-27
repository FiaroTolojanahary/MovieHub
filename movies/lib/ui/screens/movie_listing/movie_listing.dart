import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:movie_data/movie_data.dart';
import 'package:flutter_application_1/providers.dart';
import 'package:flutter_application_1/router/app_routes.dart';
import 'package:flutter_application_1/ui/widgets/movie_widget.dart';
import 'package:flutter_application_1/ui/theme/theme.dart';
import 'package:flutter_application_1/ui/widgets/movie_row.dart';
import 'package:flutter_application_1/ui/widgets/not_ready.dart';
import 'package:flutter_application_1/ui/movie_viewmodel.dart';

const movieRowHeight = 140;

@RoutePage(name: 'MovieListingRoute')
class MovieListing extends ConsumerStatefulWidget {
  final MovieType movieType;

  const MovieListing(this.movieType, {super.key});

  @override
  ConsumerState<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends ConsumerState<MovieListing> {
  late MovieViewModel movieViewModel;

  int totalPagesAvailable = 0;
  // Chapitre 18 : contrôleur de défilement explicite, utilisé par le test
  // d'intégration (sinon PagedListView.controller vaut null).
  final _scrollController = ScrollController();

  // infinite_scroll_pagination 5 : le contrôleur reçoit directement
  // la fonction qui calcule la page suivante et celle qui charge une page.
  // (4.x : PagingController(firstPageKey: 0) + addPageRequestListener + appendPage)
  late final _pagingController = PagingController<int, MovieResults>(
    // TMDB : pages 1..totalPages. nextIntPageKey vaut 1 pour la première page.
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) return null;
      final next = state.nextIntPageKey;
      if (totalPagesAvailable > 0 && next > totalPagesAvailable) return null;
      return next;
    },
    fetchPage: _fetchMovies,
  );

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieViewModelAsync = ref.watch(movieViewModelProvider);
    return movieViewModelAsync.when(
      error: (e, st) => Text(e.toString()),
      loading: () => const NotReady(),
      data: (viewModel) {
        movieViewModel = viewModel;
        return buildScreen();
      },
    );
  }

  Widget buildScreen() {
    // Plus de FutureBuilder(future: loadMovies()) : il relançait un chargement
    // à chaque reconstruction. C'est PagingListener qui demande les pages.
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: screenBackground,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              context.router.maybePopTop();
            },
          ),
          centerTitle: false,
          title: Text('Back', style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: Container(
          color: screenBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16.0, 0.0, 24.0),
                child: Text(getTitle(), style: Theme.of(context).textTheme.titleLarge),
              ),
              const Divider(),
              Expanded(
                child: PagingListener(
                  controller: _pagingController,
                  builder: (context, state, fetchNextPage) =>
                      PagedListView<int, MovieResults>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    scrollController: _scrollController,
                    builderDelegate: PagedChildBuilderDelegate<MovieResults>(
                      itemBuilder: (context, item, index) => MovieRow(
                        movie: item,
                        movieViewModel: movieViewModel,
                        onMovieTap: (movie) {
                          context.router
                              .push(MovieDetailRoute(movieId: item.id));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTitle() {
    switch (widget.movieType) {
      case MovieType.trending:
        return 'Trending';
      case MovieType.popular:
        return 'Popular';
      case MovieType.topRated:
        return 'Top Rated';
      case MovieType.nowPlaying:
        return 'Now Playing';
    }
  }

  void onMovieTap(int movieId) {
    context.router.push(MovieDetailRoute(movieId: movieId));
  }

  /// Charge une page (remplace loadMovies() du livre).
  /// Renvoie la liste des films ; la fin est signalée par getNextPageKey.
  Future<List<MovieResults>> _fetchMovies(int page) async {
    final MovieResponse? response = switch (widget.movieType) {
      MovieType.trending => await movieViewModel.getTrendingMovies(page),
      MovieType.popular => await movieViewModel.getPopular(page),
      MovieType.topRated => await movieViewModel.getTopRated(page),
      MovieType.nowPlaying => await movieViewModel.getNowPlaying(page),
    };
    if (response == null) return const [];
    totalPagesAvailable = response.totalPages;
    return response.results;
  }
}
