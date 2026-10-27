import 'package:flutter/material.dart';
import 'package:movie_data/movie_data.dart';

import 'package:flutter_application_1/ui/theme/theme.dart';

class MovieOverview extends StatelessWidget {
  final MovieDetails details;

  const MovieOverview({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Text(
        details.overview,
        style: body1Regular,
      ),
    );
  }
}
