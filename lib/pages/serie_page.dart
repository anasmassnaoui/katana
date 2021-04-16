import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/episode.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/models/quality.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/utils/selector.dart';
import 'package:katana/widgets/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:seekbar/seekbar.dart';
import '../blocs/catalogue_bloc.dart';

class SeriePage extends StatefulWidget {
  final String link;
  final String title;

  const SeriePage({Key key, this.link, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SeriePageState();
}

class SeriePageState extends State<SeriePage> {
  //ScrollController controller = ScrollController();
  int nextSeason = 0;
  int currentSeason;
  int currentEpisode;
  bool fullScreen = false;
  List<Season> seasons = [];
  bool playerMode = false;

  void onPlay(int _currentSeason, int _currentEpisode) async {
    setState(() {
      currentSeason = _currentSeason;
      currentEpisode = _currentEpisode;
      playerMode = true;
    });
    // String link = seasons[currentSeason].episodes[currentEpisode].link;
    // final qualities = await getIt<EgybestRipository>().getVideoQualities(link);
    // final title =
    //     '${seasons[currentSeason].title} ${seasons[currentSeason].episodes[currentEpisode].title}';
    // play(title, qualities,
    //     onNext: currentSeason < seasons.length &&
    //             currentEpisode < seasons[currentSeason].episodes.length
    //         ? () {
    //             if (currentEpisode < seasons[currentSeason].episodes.length)
    //               currentEpisode++;
    //             else if (currentSeason < seasons.length) {
    //               currentEpisode = 0;
    //               currentSeason++;
    //             }
    //             onPlay(currentSeason, currentEpisode);
    //           }
    //         : null,
    //     onPrev: currentSeason > 0 || currentEpisode > 0
    //         ? () {
    //             if (currentEpisode > 0)
    //               currentEpisode--;
    //             else if (currentSeason > 0) {
    //               currentEpisode = 0;
    //               currentSeason--;
    //             }
    //             onPlay(currentSeason, currentEpisode);
    //           }
    //         : null);
  }

  @override
  void dispose() {
    super.dispose();
    //disposePlayer();
  }

  // Future<void> disposePlayer() async {
  //   await videoPlayerController.dispose();
  //   chewieController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () => null,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        // constraints: BoxConstraints(
        //   maxHeight: (() {
        //     if (playerMode)
        //       return MediaQuery.of(context).size.height - (!fullScreen ? 30 : 0);
        //     return MediaQuery.of(context).size.height * 0.8;
        //   })(),
        // ),
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 1.0,
        expand: false,
        builder: (_, controller) =>
            NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowGlow();
            return true;
          },
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(playerMode ? 0.0 : 30.0),
            ),
            child: Container(
              color: ThemeData.dark().scaffoldBackgroundColor,
              child: BlocProvider(
                create: (context) =>
                    getIt<CatalogueBloc>()..add(SerieEvent(link: widget.link)),
                child: BlocBuilder<CatalogueBloc, BlocState>(
                  builder: (context, state) {
                    if (state is SerieState) {
                      Serie serie = state.serie;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          playerMode
                              ? PlayerWithControls(
                                  title: 'fffff',
                                  link: seasons[currentSeason]
                                      .episodes[currentEpisode]
                                      .link,
                                  onFullScreen: (_fullscreen) =>
                                      setState(() => fullScreen = _fullscreen),
                                )
                              : SerieView(
                                  image: serie.image,
                                  title: serie.title,
                                  type: serie.type,
                                  seasons: serie.seasons.length,
                                ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: controller,
                              child: Column(
                                children: [
                                  SerieInfo(
                                    title: serie.title,
                                    story: serie.story,
                                  ),
                                  BlocProvider(
                                    create: (context) => getIt<CatalogueBloc>(),
                                    child:
                                        BlocBuilder<CatalogueBloc, BlocState>(
                                      buildWhen: (previous, current) =>
                                          current is SeasonState,
                                      builder: (context, state) {
                                        if (state is SeasonState &&
                                            nextSeason++ < serie.seasons.length)
                                          seasons.add(Season(
                                            title: serie.seasons[nextSeason - 1]
                                                ['title'],
                                            link: state.season.link,
                                            episodes: state.season.episodes,
                                          ));
                                        return LoadSeasons(
                                          loadedSeasons: seasons,
                                          currentSeason: nextSeason,
                                          seasonsSchema: serie.seasons,
                                          controller: controller,
                                          onPlay: onPlay,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Loading(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    setState(() => loading = false);
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
        child: child,
      );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return buildHeight(
        child: Container(
          height: 350,
          child: Loading(),
        ),
      );
    return buildHeight(
      aspectRatio: videoPlayerController.value.aspectRatio,
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
                    iconSize: 40,
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
                            size: 30,
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
                        ),
                        Expanded(
                          child: SeekBar(
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

class SerieInfo extends StatelessWidget {
  final String title;
  final String story;

  const SerieInfo({Key key, this.title, this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Text(
            story,
            textDirection: story.contains(RegExp(r'[\u0600-\u06FF]'))
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class LoadSeasons extends StatefulWidget {
  final List<Season> loadedSeasons;
  final int currentSeason;
  final List<Map<String, dynamic>> seasonsSchema;
  final ScrollController controller;
  final void Function(int, int) onPlay;

  const LoadSeasons({
    Key key,
    this.loadedSeasons,
    this.currentSeason,
    this.seasonsSchema,
    this.controller,
    this.onPlay,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadSeasonsState();
}

class LoadSeasonsState extends State<LoadSeasons> {
  bool loaded = false;
  bool disableNonScrollEffect = false;

  @override
  void initState() {
    super.initState();
    dispatchLoadSeason();
    widget.controller.addListener(() => loadCurrentSeason());
  }

  void loadCurrentSeason() {
    if (!loaded &&
        widget.currentSeason < widget.seasonsSchema.length &&
        widget.controller.position.pixels >=
            widget.controller.position.maxScrollExtent - 60) {
      loaded = true;
      disableNonScrollEffect = true;
      dispatchLoadSeason();
    }
  }

  void dispatchLoadSeason() {
    BlocProvider.of<CatalogueBloc>(context).add(
      SeasonEvent(
        link: widget.seasonsSchema[widget.currentSeason]['link'],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LoadSeasons oldWidget) {
    super.didUpdateWidget(oldWidget);
    loaded = false;
    if (!disableNonScrollEffect) loadCurrentSeason();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  widget.seasonsSchema[index]['title'],
                  textAlign: TextAlign.end,
                ),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemBuilder: (_, _index) => EpisodeView(
                    episode: widget.loadedSeasons[index].episodes[_index],
                    onPlay: (_) => widget.onPlay(index, _index),
                  ),
                  itemCount: widget.loadedSeasons[index].episodes.length,
                ),
              ),
            ],
          ),
          separatorBuilder: (context, index) => Divider(),
          itemCount: widget.loadedSeasons.length,
        ),
        widget.currentSeason < widget.seasonsSchema.length
            ? Container(
                padding: EdgeInsets.all(5.0),
                child: Loading(),
              )
            : Container(),
      ],
    );
  }
}

class NetworkImage extends StatelessWidget {
  final String link;

  const NetworkImage({Key key, this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      link,
      headers: getIt<Client>().headers,
      loadingBuilder: (context, child, loadingProgress) =>
          (loadingProgress == null ||
                  loadingProgress.cumulativeBytesLoaded ==
                      loadingProgress.expectedTotalBytes)
              ? child
              : Loading(),
    );
  }
}

class RoundedBox extends StatelessWidget {
  final double radius;
  final Widget child;
  final bool isExpand;

  const RoundedBox({Key key, this.radius, this.child, this.isExpand: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: isExpand ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class SerieView extends StatelessWidget {
  final String image;
  final String title;
  final String type;
  final int seasons;

  const SerieView({Key key, this.image, this.title, this.type, this.seasons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30.0),
              ),
              child: NetworkImage(link: image),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 8.0,
                        ),
                        child: RoundedBox(
                          radius: 20,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RoundedBox(
                          radius: 50,
                          child: Icon(
                            Icons.close,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedBox(
                          radius: 20,
                          isExpand: true,
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedBox(
                          radius: 20,
                          isExpand: true,
                          child: Text(
                            'عدد المواسم : ' + seasons.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeView extends StatelessWidget {
  final Episode episode;
  final void Function(String) onPlay;
  final void Function(String) onDownload;

  const EpisodeView({
    Key key,
    @required this.episode,
    this.onPlay,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      color: Colors.black,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: NetworkImage(link: episode.image),
          ),
          Positioned.fill(
              child: IconButton(
            iconSize: 40,
            icon: Icon(CupertinoIcons.play_fill),
            onPressed: () => onPlay(episode.link),
          )),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.only(left: 5.0),
                  icon: Icon(
                    CupertinoIcons.cloud_download,
                  ),
                  onPressed: () => onDownload(episode.link),
                ),
              ),
            ),
          ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(left: 35, right: 5.0),
              child: Text(
                episode.title,
                textDirection: TextDirection.rtl,
              ),
            ),
          ))
        ],
      ),
    );
  }
}
