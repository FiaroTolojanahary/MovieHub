import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_data/movie_data.dart';

import 'package:flutter_application_1/ui/main_screen.dart';
import 'package:flutter_application_1/ui/screens/favorites/favorite_screen.dart';
import 'package:flutter_application_1/ui/screens/genres/genre_screen.dart';
import 'package:flutter_application_1/ui/screens/home/home_screen.dart';
import 'package:flutter_application_1/ui/screens/movie_detail/movie_detail.dart';
import 'package:flutter_application_1/ui/screens/movie_listing/movie_listing.dart';
import 'package:flutter_application_1/ui/screens/videos/video_page.dart';
import 'package:flutter_application_1/ui/widgets/movie_widget.dart';

part 'app_routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', initial: true, page: MainRoute.page, children: [
          AutoRoute(path: 'home', page: HomeRoute.page),
          AutoRoute(path: 'Genre', page: GenreRoute.page),
          AutoRoute(path: 'favorites', page: FavoriteRoute.page),
        ]),
        CustomRoute(
          path: '/details/:movieId',
          page: MovieDetailRoute.page,
          maintainState: false,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: VideoPageRoute.page,
          maintainState: false,
          transitionsBuilder: TransitionsBuilders.slideRight,
          duration: const Duration(milliseconds: 500),
        ),
        CustomRoute(
          page: MovieListingRoute.page,
          maintainState: false,
          transitionsBuilder: TransitionsBuilders.fadeIn,
          duration: const Duration(milliseconds: 500),
        ),
      ];
}
