import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers.dart';

// Migration Flutter 3.47 : le plugin git `menubar` (dépôt archivé) est supprimé.
// - macOS : PlatformMenuBar (menus natifs) avec createMenus(), comme dans le livre ;
// - Windows : MenuBar Material (createMaterialMenus()) dessiné dans la fenêtre,
//   + CallbackShortcuts (shortcutBindings()) pour que les raccourcis Ctrl+...
//   fonctionnent vraiment (le `shortcut:` d'un MenuItemButton n'est qu'un libellé).

sealed class MenuEvent {}

class QuitEvent extends MenuEvent {}

class HomeEvent extends MenuEvent {}

class GenreEvent extends MenuEvent {}

class FavoritesEvent extends MenuEvent {}

class SearchEvent extends MenuEvent {}

class SearchMovieEvent extends MenuEvent {
  final String searchText;

  SearchMovieEvent(this.searchText);
}

class MenuManager {
  // Riverpod 3 : ProviderRef n'existe plus, on utilise Ref.
  final Ref ref;

  MenuManager(this.ref);

  void _fire(MenuEvent event) => ref.read(eventBusProvider).fire(event);

  // ---------- macOS : menus natifs (PlatformMenuBar) ----------

  List<PlatformMenu> createMenus() {
    return [
      createMovieMenu(),
      createOptionsMenu(),
    ];
  }

  PlatformMenu createMovieMenu() {
    return PlatformMenu(label: 'Movies', menus: [
      PlatformMenuItem(
          label: 'Quit',
          onSelected: () => _fire(QuitEvent()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, meta: true)),
    ]);
  }

  PlatformMenu createOptionsMenu() {
    return PlatformMenu(label: 'Options', menus: [
      PlatformMenuItem(
          label: 'Home',
          onSelected: () => _fire(HomeEvent()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyH, meta: true)),
      PlatformMenuItem(
          label: 'Genre',
          onSelected: () => _fire(GenreEvent()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyG, meta: true)),
      PlatformMenuItem(
          label: 'Favorites',
          onSelected: () => _fire(FavoritesEvent()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyF, meta: true)),
      PlatformMenuItem(
          label: 'Search',
          onSelected: () => _fire(SearchEvent()),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true)),
    ]);
  }

  // ---------- Windows : MenuBar Material (remplace le plugin menubar) ----------

  List<Widget> createMaterialMenus() {
    return [
      createWindowsMovieMenu(),
      createWindowsOptionsMenu(),
    ];
  }

  Widget createWindowsMovieMenu() {
    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          shortcut: const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
          onPressed: () => _fire(QuitEvent()),
          child: const Text('Quit'),
        ),
      ],
      child: const Text('Movies'),
    );
  }

  Widget createWindowsOptionsMenu() {
    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          shortcut: const SingleActivator(LogicalKeyboardKey.keyH, control: true),
          onPressed: () => _fire(HomeEvent()),
          child: const Text('Home'),
        ),
        MenuItemButton(
          shortcut: const SingleActivator(LogicalKeyboardKey.keyG, control: true),
          onPressed: () => _fire(GenreEvent()),
          child: const Text('Genre'),
        ),
        MenuItemButton(
          shortcut: const SingleActivator(LogicalKeyboardKey.keyF, control: true),
          onPressed: () => _fire(FavoritesEvent()),
          child: const Text('Favorites'),
        ),
        MenuItemButton(
          shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
          onPressed: () => _fire(SearchEvent()),
          child: const Text('Search'),
        ),
      ],
      child: const Text('Options'),
    );
  }

  /// Raccourcis réellement actifs sous Windows (utilisés par CallbackShortcuts
  /// dans MainScreen).
  Map<ShortcutActivator, VoidCallback> shortcutBindings() {
    return {
      const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () =>
          _fire(QuitEvent()),
      const SingleActivator(LogicalKeyboardKey.keyH, control: true): () =>
          _fire(HomeEvent()),
      const SingleActivator(LogicalKeyboardKey.keyG, control: true): () =>
          _fire(GenreEvent()),
      const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
          _fire(FavoritesEvent()),
      const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
          _fire(SearchEvent()),
    };
  }
}
