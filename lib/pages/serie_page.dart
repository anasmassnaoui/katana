import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/episode.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/widgets/loading.dart';
import 'package:video_player/video_player.dart';

import '../blocs/catalogue_bloc.dart';

class SeriePage extends StatefulWidget {
  final String link;
  final String title;

  const SeriePage({Key key, this.link, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SeriePageState();
}

class SeriePageState extends State<SeriePage> {
  ScrollController controller = ScrollController();
  int currentSeason = 0;
  List<Season> seasons = [];
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  bool playerMode = false;
  bool playerLoading = false;

  void onPlay(link) async {
    print("link");
    setState(() {
      playerMode = true;
      playerLoading = true;
    });
    videoPlayerController = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      customControls: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                IconButton(
                    icon: Icon(CupertinoIcons.play),
                    onPressed: () => chewieController.toggleFullScreen()),
                IconButton(
                    icon: Icon(CupertinoIcons.stop),
                    onPressed: () => chewieController.toggleFullScreen()),
              ],
            ),
          )
        ],
      ),
    );
    setState(() => playerLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              (playerMode
                  ? (1 - 30 / MediaQuery.of(context).size.height)
                  : 0.8)),
      child: NotificationListener<OverscrollIndicatorNotification>(
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
                            ? SizedBox(
                                height: 300,
                                child: playerLoading
                                    ? Loading()
                                    : Container(
                                        color: Colors.black,
                                        child: Chewie(
                                          controller: chewieController,
                                        ),
                                      ),
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
                                  child: BlocBuilder<CatalogueBloc, BlocState>(
                                    buildWhen: (previous, current) =>
                                        current is SeasonState,
                                    builder: (context, state) {
                                      if (state is SeasonState &&
                                          currentSeason++ <
                                              serie.seasons.length)
                                        seasons.add(state.season);
                                      return LoadSeasons(
                                        loadedSeasons: seasons,
                                        currentSeason: currentSeason,
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
  final void Function(String) onPlay;

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
                    onPlay: widget.onPlay,
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
