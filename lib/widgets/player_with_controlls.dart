import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:seekbar/seekbar.dart';
import 'package:katana/utils/selector.dart';
import 'package:katana/models/quality.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:flutter/services.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/widgets/loading.dart';

class PlayerWithControls extends StatefulWidget {
  final void Function() onNext;
  final void Function() onPrev;
  final void Function(bool) onFullScreen;
  final String title;
  final String link;

  const PlayerWithControls({
    Key key,
    this.title,
    this.onNext,
    this.onPrev,
    this.link,
    this.onFullScreen,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerWithControlsState();
}

class PlayerWithControlsState extends State<PlayerWithControls> {
  bool showControls = true;
  bool loading = true;
  bool fullScreen = false;
  VideoPlayerController videoPlayerController;
  List<Quality> qualities;
  Quality quality;

  @override
  void didUpdateWidget(covariant PlayerWithControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link != oldWidget.link) loadVideo().then((_) => watchVideo());
  }

  @override
  void initState() {
    super.initState();
    loadVideo().then((_) => watchVideo());
  }

  Future<void> loadVideo() async {
    setState(() => loading = true);
    qualities = await getIt<EgybestRipository>().getVideoQualities(widget.link);
    quality = qualities.first;
  }

  Future<void> watchVideo() async {
    setState(() => loading = true);
    String link = await getIt<EgybestRipository>().getDirectLink(quality.link);
    removePlayer();
    videoPlayerController = VideoPlayerController.network(link);
    await videoPlayerController.initialize();
    await videoPlayerController.play();
    videoPlayerController.addListener(updateState);
    if (mounted) setState(() => loading = false);
  }

  bool getPause() => !videoPlayerController.value.isPlaying;

  void updateState() => setState(() {});

  void toggleControls() => setState(() => showControls = !showControls);

  void toggleFullScreen() {
    fullScreen = !fullScreen;
    if (fullScreen) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIOverlays([]);
      widget.onFullScreen(true);
    } else {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIOverlays(
          [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      widget.onFullScreen(false);
    }
    //setState(() => fullScreen = !fullScreen);
  }

  void togglePause() => videoPlayerController.value.isPlaying
      ? videoPlayerController.pause()
      : videoPlayerController.play();

  void seekTo(Duration duration) async {
    await videoPlayerController.seekTo(duration);
  }

  void onChangeQuality() async {
    final choice = await selectChoice(
      context,
      Future.value(qualities.map((e) => e.quality).toList()),
    );
    if (choice != null) {
      quality = qualities.firstWhere((e) => e.quality == choice);
      Duration duration = videoPlayerController.value.position;
      await watchVideo();
      seekTo(duration);
    }
  }

  String duratioToString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour) as int);
    String twoDigitSeconds = twoDigits(
        duration.inSeconds.remainder(Duration.secondsPerMinute) as int);
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    super.dispose();
    if (fullScreen) toggleFullScreen();
    removePlayer();
  }

  void removePlayer() {
    if (videoPlayerController != null) {
      videoPlayerController.removeListener(updateState);
      videoPlayerController.dispose();
    }
  }

  Widget buildHeight({Widget child, double aspectRatio}) {
    if (fullScreen)
      return Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        child: child,
      );
    if (aspectRatio != null)
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          child: child,
          color: Colors.black,
        ),
      );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return buildHeight(
        aspectRatio: 1.5,
        child: Loading(),
      );
    return buildHeight(
      aspectRatio: 1.5, //videoPlayerController.value.aspectRatio,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: VideoPlayer(
                videoPlayerController,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => toggleControls(),
            child: Container(
              color: Colors.black.withOpacity(showControls ? 0.5 : 0.0),
            ),
          ),
          Visibility(
            visible: showControls,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.title)),
                    GestureDetector(
                      onTap: () => onChangeQuality(),
                      child: Icon(
                        Icons.more_vert,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: showControls,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  Spacer(),
                  Opacity(
                    opacity: widget.onPrev != null ? 1 : 0,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.skip_previous),
                      onPressed: widget.onPrev,
                    ),
                  ),
                  IconButton(
                    iconSize: 60,
                    icon: Icon(getPause() ? Icons.play_arrow : Icons.pause),
                    onPressed: () => togglePause(),
                  ),
                  Opacity(
                    opacity: widget.onNext != null ? 1 : 0,
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.skip_next),
                      onPressed: widget.onNext,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          Visibility(
            visible: showControls,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () => toggleFullScreen(),
                          child: Icon(
                            Icons.fullscreen,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      bottom: 10.0,
                      top: 5.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          duratioToString(
                            videoPlayerController.value.position,
                          ),
                          style: TextStyle(fontSize: 17),
                        ),
                        Expanded(
                          child: SeekBar(
                            progressWidth: 4.0,
                            thumbRadius: 10,
                            value: videoPlayerController
                                    .value.position.inMilliseconds /
                                videoPlayerController
                                    .value.duration.inMilliseconds,
                            onProgressChanged: (value) {
                              Duration duration = Duration(
                                  milliseconds: (value *
                                          videoPlayerController
                                              .value.duration.inMilliseconds)
                                      .toInt());
                              seekTo(duration);
                            },
                          ),
                        ),
                        Text(
                          duratioToString(
                            videoPlayerController.value.duration,
                          ),
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
