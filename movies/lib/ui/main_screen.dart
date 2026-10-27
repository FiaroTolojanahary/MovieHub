import 'dart:async';
import 'dart:ui' show AppExitType;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_application_1/providers.dart';
import 'package:flutter_application_1/ui/menus.dart';
import 'package:flutter_application_1/ui/screens/favorites/favorite_screen.dart';
import 'package:flutter_application_1/ui/screens/genres/genre_screen.dart';
import 'package:flutter_application_1/ui/screens/genres/search_dialog.dart';
import 'package:flutter_application_1/ui/screens/home/home_screen.dart';
import 'package:flutter_application_1/ui/theme/theme.dart';
import 'package:flutter_application_1/utils/utils.dart';

// Migration Flutter 3.47 : flutter_adaptive_scaffold (abandonné) est remplacé
// par un LayoutBuilder : NavigationRail à partir de 600 px de large
// (= Breakpoints.mediumAndUp), BottomNavigationBar en dessous (= Breakpoints.small).

@RoutePage()
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int currentIndex = 0;
  List<Widget> tabScreens = [];
  // Abonnement à l'EventBus, annulé dans dispose() (oubli du livre).
  StreamSubscription<MenuEvent>? menuSubscription;

  @override
  void initState() {
    super.initState();
    tabScreens.add(const HomeScreen());
    tabScreens.add(const GenreScreen());
    tabScreens.add(const FavoriteScreen());

    menuSubscription =
        ref.read(eventBusProvider).on<MenuEvent>().listen((event) {
      switch (event) {
        case HomeEvent():
          setState(() {
            currentIndex = 0;
            ref.read(currentIndexProvider.notifier).state = currentIndex;
          });
        case GenreEvent():
          setState(() {
            currentIndex = 1;
            ref.read(currentIndexProvider.notifier).state = currentIndex;
          });
        case FavoritesEvent():
          setState(() {
            currentIndex = 2;
            ref.read(currentIndexProvider.notifier).state = currentIndex;
          });
        case QuitEvent():
          if (isDesktop()) {
            // SystemNavigator.pop() ne ferme pas l'app sur bureau.
            ServicesBinding.instance.exitApplication(AppExitType.required);
          } else {
            SystemNavigator.pop();
          }
        case SearchEvent():
          showDialog(
              context: context, builder: (context) => const SearchDialog());

        case SearchMovieEvent():
          ref.read(searchTextProvider.notifier).state = event.searchText;
          currentIndex = 1;
          ref.read(currentIndexProvider.notifier).state = currentIndex;
      }
    });
  }

  @override
  void dispose() {
    menuSubscription?.cancel();
    super.dispose();
  }

  void selectTab(int index) {
    setState(() {
      currentIndex = index;
      ref.read(currentIndexProvider.notifier).state = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = ref.watch(currentIndexProvider);
    final layout = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 600) {
          // Grand écran (bureau, web, tablette) : rail de navigation à gauche
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.black,
                  selectedIndex: currentIndex,
                  onDestinationSelected: selectTab,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedIconTheme:
                      const IconThemeData(color: posterBorder),
                  selectedLabelTextStyle: const TextStyle(color: Colors.white),
                  unselectedLabelTextStyle:
                      const TextStyle(color: posterBorder),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Symbols.genres),
                      label: Text('Genre'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                ),
                // Chapitre 17 : IndexedStack garde l'état de chaque onglet
                Expanded(
                    child: IndexedStack(
                        index: currentIndex, children: tabScreens)),
              ],
            ),
          );
        }
        // Petit écran (téléphone) : barre de navigation en bas.
        // (Chapitre 16 : le livre retire le SizedBox(height: 80) autour de la
        // BottomNavigationBar ; notre version n'en avait déjà pas.)
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: tabScreens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: selectTab,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.genres),
                label: 'Genre',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
            ],
          ),
        );
      },
    );

    // macOS : menus natifs via PlatformMenuBar (main.dart).
    // Mobile / web : pas de menu.
    if (!isWindows()) {
      return layout;
    }
    // Windows : barre de menus Material dans la fenêtre + raccourcis Ctrl+...
    final menuManager = ref.read(menuManagerProvider);
    return CallbackShortcuts(
      bindings: menuManager.shortcutBindings(),
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MenuBar(children: menuManager.createMaterialMenus()),
                ),
              ],
            ),
            Expanded(child: layout),
          ],
        ),
      ),
    );
  }
}
