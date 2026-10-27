import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_data/src/data/database/database_interface.dart';
import 'package:movie_data/src/data/database/models/configuration.dart';
import 'package:movie_data/src/data/database/models/favorite.dart';
import 'package:movie_data/src/data/database/models/genre.dart';


const favorites = 'favorites';
const genres = 'genres';
const configuration = 'configuration';
const images = 'images';

class FirebaseDatabase implements IDatabase {
  final firebase = FirebaseFirestore.instance;
  final favoritesCollection = FirebaseFirestore.instance.collection(favorites);
  final genresCollection = FirebaseFirestore.instance.collection(genres);
  final configurationCollection =
      FirebaseFirestore.instance.collection(configuration);
  final imagesCollection = FirebaseFirestore.instance.collection(images);

  // Chapitre 16 : movie_data ne connaît pas firebase_options.dart (il est dans
  // l'app). Les options sont injectées par le provider `firebase` de l'app.
  // Firebase.initializeApp(...) reste appelé dans main.dart de l'app.
  final FirebaseOptions options;

  FirebaseDatabase(this.options);

  @override
  Future deleteDatabase() {
    return Future.value(null);
  }

  @override
  Future<List<DBFavorite>> getFavorites() async {
    final favorites = <DBFavorite>[];
    final querySnapshot = await favoritesCollection.get();
    for (final doc in querySnapshot.docs) {
      var favorite = DBFavorite.fromJson(doc.data());
      favorite = favorite.copyWith(id: int.tryParse(doc.id) ?? 0);
      favorites.add(favorite);
    }
    return favorites;
  }

  @override
  Stream<List<DBFavorite>> streamFavorites() {
    return favoritesCollection
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((doc) => DBFavorite.fromJson(doc.data()))
            .toList())
        .asBroadcastStream();
  }

  @override
  Future<bool> removeFavorite(int id) async {
    final ref = await favoritesCollection.where('id', isEqualTo: id).get();
    if (ref.docs.isNotEmpty) {
      // await ajouté (le livre n'attendait pas la suppression)
      await ref.docs[0].reference.delete();
    }
    return Future.value(true);
  }

  @override
  Future saveFavorite(DBFavorite favorite) async {
    final ref = await favoritesCollection.add(favorite.toJson());
    return Future.value(ref.id);
  }

  @override
  Future<List<DBMovieGenre>> getGenres() async {
    final genres = <DBMovieGenre>[];
    final querySnapshot = await genresCollection.get();
    for (final doc in querySnapshot.docs) {
      var genre = DBMovieGenre.fromJson(doc.data());
      genre = genre.copyWith(id: int.tryParse(doc.id) ?? 0);
      genres.add(genre);
    }
    return genres;
  }

  @override
  Future saveGenres(List<DBMovieGenre> genres) async {
    for (final genre in genres) {
      // await ajouté (le livre n'attendait pas l'écriture)
      await genresCollection.add(genre.toJson());
    }
  }


  @override
  Future<DBConfiguration?> getMovieConfiguration() async {
    final querySnapshot = await configurationCollection.get();
    for (final doc in querySnapshot.docs) {
      var configuration = DBConfiguration.fromJson(doc.data());
      configuration = configuration.copyWith(id: int.tryParse(doc.id) ?? 0);
      final imagesSnapshot = await imagesCollection.get();
      if (imagesSnapshot.docs.isNotEmpty) {
        final images =
            DBConfigurationImages.fromJson(imagesSnapshot.docs[0].data());
        configuration = configuration.copyWith(images: images);
      }
      return configuration;
    }
    return Future.value(null);
  }

  @override
  Future<DBConfiguration?> getMovieConfigurationById(int id) async {
    final docRef = await configurationCollection.doc(id.toString()).get();
    final data = docRef.data();
    if (data != null) {
      return DBConfiguration.fromJson(data);
    }
    return null;
  }

  @override
  Future saveMovieConfiguration(DBConfiguration configuration) async {
    final configJson = configuration.toJson();
    debugPrint(configJson.toString()); // print -> debugPrint (lint avoid_print)
    // await ajouté (le livre n'attendait pas l'écriture)
    await configurationCollection.add(configJson);
  }
}
