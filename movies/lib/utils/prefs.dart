import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:movie_plugin/movie_plugin.dart';

/// Chapitre 17 : les préférences passent par notre plugin natif movie_plugin
/// (SharedPreferences sur Android, UserDefaults sur iOS).
///
/// Différence avec le livre : movie_plugin n'existe que pour Android et iOS.
/// Sous Edge (web) ou Windows, le canal n'a pas d'implémentation et lève une
/// MissingPluginException : on l'intercepte pour que l'app continue
/// (les genres ne sont simplement pas mémorisés sur ces plateformes).
class Prefs {
  final MoviePlugin preferences;

  Prefs(this.preferences);

  Future<T?> _safe<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } on MissingPluginException catch (e) {
      debugPrint('movie_plugin indisponible sur cette plateforme : $e');
      return null;
    }
  }

  Future setString(String key, String value) async {
    await _safe(() async => await preferences.setString(key, value));
  }

  Future<String?> getString(String key) async {
    return _safe(() => preferences.getString(key));
  }

  Future setInt(String key, int value) async {
    await _safe(() async => await preferences.setInt(key, value));
  }

  Future<int?> getInt(String key) async {
    return _safe(() => preferences.getInt(key));
  }

  Future setBool(String key, bool value) async {
    await _safe(() async => await preferences.setBool(key, value));
  }

  Future<bool?> getBool(String key) async {
    return _safe(() => preferences.getBool(key));
  }

  Future setDouble(String key, double value) async {
    await _safe(() async => await preferences.setDouble(key, value));
  }

  Future<double?> getDouble(String key) async {
    return _safe(() => preferences.getDouble(key));
  }
}
