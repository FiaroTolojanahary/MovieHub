import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'movie_database.g.dart';

class DriftConfigurationImages extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get baseUrl => text()();

  TextColumn get secureBaseUrl => text()();

  TextColumn get backdropSizes => text()();

  TextColumn get logoSizes => text()();

  TextColumn get posterSizes => text()();

  TextColumn get profileSizes => text()();

  TextColumn get stillSizes => text()();
}

class DriftFavorite extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get movieId => integer()();

  TextColumn get backdropPath => text()();

  TextColumn get posterPath => text()();

  BoolColumn get favorite => boolean()();

  RealColumn get popularity => real()();

  DateTimeColumn get releaseDate => dateTime()();

  TextColumn get title => text()();

  TextColumn get overview => text()();
}

class DriftGenre extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  TextColumn get name => text()();
}

@DriftDatabase(
  tables: [DriftFavorite, DriftConfigurationImages, DriftGenre],
)
class MovieDatabase extends _$MovieDatabase {
  // Migration : la connexion du livre (connection.dart, native.dart, web.dart,
  // unsupported.dart) est remplacée par driftDatabase() de drift_flutter.
  // L'import drift_flutter, retiré par le livre au chapitre 14, reste donc nécessaire.
  MovieDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      // natif : <getApplicationDocumentsDirectory()>/movies.sqlite
      name: 'movies',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            debugPrint('Using ${result.chosenImplementation} due to unsupported '
                'browser features: ${result.missingFeatures}');
          }
        },
      ),
    );
  }
}
