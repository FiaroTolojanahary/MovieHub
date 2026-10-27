import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:movie_data/movie_data.dart';
// Généré par `flutterfire configure` dans TON projet (non fourni).
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/ui/screens/home/title_row.dart';
import 'package:flutter_application_1/ui/widgets/movie_row.dart';
import 'package:flutter_application_1/utils/utils.dart';

void main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  WidgetsFlutterBinding.ensureInitialized();
  putLumberdashToWork(withClients: [
    ColorizeLumberdash(),
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!isWeb()) {
    await dotenv.load(fileName: '.env');
  }

  testWidgets('Test scrolling the Movie Listing', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final moreButtonFinder = find.byType(TitleRow);
    expect(moreButtonFinder, findsAtLeast(1));
    final firstMoreButton = moreButtonFinder.first;
    final textButtonFinder =
        find.descendant(of: firstMoreButton, matching: find.byType(TextButton));
    await tester.tap(textButtonFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // infinite_scroll_pagination 5 : la PagedListView ne porte plus de
    // pagingController ; elle reçoit un PagingState (state) du PagingListener.
    final movieListFinder = find.byType(PagedListView<int, MovieResults>);
    expect(movieListFinder, findsOneWidget);
    var movieList =
        tester.widget<PagedListView<int, MovieResults>>(movieListFinder);
    // ScrollView.controller = le _scrollController ajouté dans MovieListing
    final controller = movieList.controller;
    expect(controller, isNotNull);

    final renderRow =
        tester.renderObject(find.byType(MovieRow).first) as RenderBox;
    final rowHeight = renderRow.size.height;
    final pageHeight = rowHeight * 20; // 20 items/page
    var currentPosition = pageHeight;
    for (var i = 0; i < 5; i++) {
      controller?.jumpTo(
        currentPosition,
      );
      currentPosition += pageHeight;
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Le PagingListener reconstruit la liste avec un nouvel état :
    // on relit donc le widget avant de compter les films chargés.
    // (4.x : pagingController.itemList?.length)
    movieList =
        tester.widget<PagedListView<int, MovieResults>>(movieListFinder);
    expect(movieList.state.items?.length, 120); // 6 pages x 20
  });
}
