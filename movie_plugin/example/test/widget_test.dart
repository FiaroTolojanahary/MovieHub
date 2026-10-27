// Test de widget de l'app d'exemple du plugin.
//
// Différence avec le livre : le fichier généré (et repris par le livre)
// cherchait le texte « Running on: » de l'ancien exemple getPlatformVersion,
// qui n'existe plus depuis le chapitre 17 : il échouait toujours.
// On vérifie à la place que l'écran d'exemple s'affiche.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_plugin_example/main.dart';

void main() {
  testWidgets('Verify example screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Le titre et les 4 sections (String, Int, Bool, Double) sont affichés.
    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.text('Current String Value is '), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Set Value'), findsWidgets);
  });
}
