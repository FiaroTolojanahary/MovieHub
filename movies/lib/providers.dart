import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 : StateProvider n'est plus exporté par flutter_riverpod.dart
import 'package:flutter_riverpod/legacy.dart';
// Chapitre 16 : toutes les classes de données viennent du package movie_data
import 'package:movie_data/movie_data.dart';
// Chapitre 17 : notre propre plugin natif (Kotlin / Swift)
import 'package:movie_plugin/movie_plugin.dart';
// Généré par `flutterfire configure` dans TON projet (non fourni).
// movie_data ne le connaît pas : on lui passe les options (provider firebase).
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/ui/menus.dart';
import 'package:flutter_application_1/utils/prefs.dart';
import 'package:flutter_application_1/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_application_1/router/app_routes.dart';
import 'package:flutter_application_1/ui/movie_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'providers.g.dart';

final heroTagProvider = StateProvider<String>((ref) {
  return '';
});

final searchTextProvider = StateProvider<String>((ref) {
  return '';
});

final currentIndexProvider = StateProvider<int>((ref) {
  return 0;
});


@Riverpod(keepAlive: true)
MenuManager menuManager(Ref ref) => MenuManager(ref);

@Riverpod(keepAlive: true)
EventBus eventBus(Ref ref) => EventBus();

@Riverpod(keepAlive: true)
Future<MovieAPIService> movieAPIService(Ref ref) async {
  // Chapitre 16 : la clé TMDB est lue ici (et plus dans movie_data)
  String apiKey;
  if (!isWeb()) {
    apiKey = dotenv.env['TMDB_KEY']!;
  } else {
    apiKey = await webLoad();
  }
  final service = MovieAPIService(apiKey);
  await service.init();
  return service;
}

Future<String> webLoad() async {
  String apiKey = '';
  try {
    final dotEnvString = await rootBundle.loadString('dotenv');
    if (dotEnvString.contains('TMDB_KEY')) {
      final parts = dotEnvString.split('=');
      if (parts.length == 2) {
        // trim() : retire le retour à la ligne final (CRLF sous Windows)
        apiKey = parts[1].trim();
        if (apiKey.contains("'")) {
          apiKey = apiKey.replaceAll("'", "");
        }
      }
    } else {
      apiKey = dotEnvString.trim();
    }
  } catch (e) {
    // print -> debugPrint (lint avoid_print)
    debugPrint(e.toString());
  }
  return apiKey;
}


@Riverpod(keepAlive: true)
Future<MovieSource> networkMovieSource(Ref ref) async {
  final service = await ref.read(movieAPIServiceProvider.future);
  return NetworkMovieSource(service);
}

@Riverpod(keepAlive: true)
Future<MovieSource> movieRepository(Ref ref) async {
  // Chapitre 19 : databaseProvider est devenu synchrone (plus de .future).
  // Riverpod 3 : les watch sont lancés AVANT le premier await.
  final database = ref.watch(databaseProvider);
  final serviceFuture = ref.watch(networkMovieSourceProvider.future);
  return MovieRepository(
      await serviceFuture, database);
}

@Riverpod(keepAlive: true)
Future<MovieViewModel> movieViewModel(Ref ref) async {
  final repositoryFuture = ref.watch(movieRepositoryProvider.future);
  final model = MovieViewModel(await repositoryFuture);
  await model.setup();
  return model;
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPrefs(Ref ref) =>
    SharedPreferences.getInstance();

// Chapitre 17 : Prefs passe par movie_plugin (et n'est plus un FutureProvider).
// Le provider sharedPrefs ci-dessus reste, comme dans le livre, mais n'est plus utilisé.
@Riverpod(keepAlive: true)
Prefs prefs(Ref ref) {
  return Prefs(ref.read(moviePluginProvider));
}

@Riverpod(keepAlive: true)
MoviePlugin moviePlugin(Ref ref) {
  return MoviePlugin();
}

@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter();

// Chapitre 19 : database, firebase et driftDatabase deviennent synchrones
// (IDatabase au lieu de Future<IDatabase>).
@Riverpod(keepAlive: true)
IDatabase database(Ref ref) {
  // Change this to what we want to use
  // return ref.read(driftDatabaseProvider);
  return ref.read(firebaseProvider);
}

@Riverpod(keepAlive: true)
IDatabase firebase(Ref ref) {
  // Injection des options Firebase de l'app dans movie_data
  return FirebaseDatabase(DefaultFirebaseOptions.currentPlatform);
}

@Riverpod(keepAlive: true)
IDatabase driftDatabase(Ref ref) {
  return DriftDatabase();
}
