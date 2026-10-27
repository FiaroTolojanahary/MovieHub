// Migration (flutter_lints 6, lint unnecessary_library_name) : `library movie_data;`
// devient `library;`. Le reste du fichier est identique au livre.
library;

export 'src/data/models/models.dart';
export 'src/data/database/models/database_models.dart';
export 'src/data/database/firebase/firebase_database.dart';
export 'src/data/database/firebase/firebase_auth.dart';
export 'src/data/database/drift/drift_database.dart';
export 'src/data/repository/movie_repository.dart';
export 'src/data/sources/database_source.dart';
export 'src/data/sources/movie_source.dart';
export 'src/data/sources/network_movie_source.dart';
export 'src/network/movie_api_service.dart';
export 'src/data/database/database_interface.dart';
