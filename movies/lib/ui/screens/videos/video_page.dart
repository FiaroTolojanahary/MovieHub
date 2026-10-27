import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_data/movie_data.dart';
import 'package:url_launcher/url_launcher.dart';
// pod_player (abandonné) est remplacé par youtube_player_flutter 10
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter_application_1/utils/utils.dart';
import 'package:flutter_application_1/ui/theme/theme.dart';

@RoutePage(name: 'VideoPageRoute')
class VideoPage extends ConsumerStatefulWidget {
  final MovieVideo movieVideo;

  const VideoPage(this.movieVideo, {super.key});

  @override
  ConsumerState<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<VideoPage> {
  // null sous Windows/Linux : youtube_player_flutter n'y fonctionne pas.
  YoutubePlayerController? _controller;

  // Le lecteur ne fonctionne que sur Web, Android, iOS et macOS.
  bool get _playerSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    if (_playerSupported) {
      // movieVideo.key est l'identifiant YouTube de la bande-annonce
      // Chapitre 19 : réglages du livre (YoutubePlayerFlags de la v9)
      // transposés en youtube_player_flutter 10.
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.movieVideo.key,
        // livre : autoPlay: true. Les navigateurs bloquent l'autoplay avec le
        // son : on démarre en pause sur le web.
        autoPlay: !kIsWeb,
        params: const YoutubePlayerParams(
          // livre : hideControls: true. Sur le web la vidéo démarre en pause :
          // on y garde les contrôles YouTube pour pouvoir lancer la lecture.
          showControls: kIsWeb,
          mute: false,
          showFullscreenButton: false, // livre : showLiveFullscreenButton: false
          loop: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close(); // v9 : dispose()
    // Chapitre 19 : on rend la main au réglage d'orientation par défaut
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    super.dispose();
  }

  Widget getVideoPlayer(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: screenBackground,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            context.router.maybePop();
          },
        ),
        centerTitle: false,
        title: Text('Back', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: screenBackground,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _controller != null
                    ? YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
                    // Repli Windows/Linux : ouvrir la vidéo dans le navigateur
                    : FilledButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ouvrir sur YouTube'),
                        onPressed: () => launchUrl(
                          Uri.parse(youtubeUrlFromId(widget.movieVideo.key)),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
// To unlock (allow any orientation):
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return getVideoPlayer(context);
  }
}
