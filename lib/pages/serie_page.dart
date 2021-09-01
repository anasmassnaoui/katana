import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/widgets/loading.dart';
import 'package:katana/widgets/player_with_controlls.dart';
import 'package:katana/widgets/seasons_loader.dart';
import 'package:katana/widgets/serie_info.dart';
import 'package:katana/widgets/serie_view.dart';
import '../blocs/catalogue_bloc.dart';

class SeriePage extends StatefulWidget {
  final String link;
  final String title;

  const SeriePage({Key key, this.link, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SeriePageState();
}

class SeriePageState extends State<SeriePage> {
  int nextSeason = 0;
  int currentSeason;
  int currentEpisode;
  bool fullScreen = false;
  List<Season> seasons = [];
  bool playerMode = false;

  void onPlay(
    int _currentSeason,
    int _currentEpisode,
  ) async {
    setState(() {
      currentSeason = _currentSeason;
      currentEpisode = _currentEpisode;
      playerMode = true;
    });
    // currentSeason = _currentSeason;
    // currentEpisode = _currentEpisode;
    // playerMode = true;
    //DraggableScrollableActuator.reset(context);
  }

  Widget buildBody({ScrollController controller}) {
    return NotificationListener<OverscrollIndicatorNotification>(
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
              key: Key('bloc'),
              builder: (context, state) {
                if (state is SerieState) {
                  Serie serie = state.serie;
                  return Column(
                    children: [
                      playerMode
                          ? PlayerWithControls(
                              title:
                                  '${seasons[currentSeason].title} ${seasons[currentSeason].episodes[currentEpisode].title}',
                              link: seasons[currentSeason]
                                  .episodes[currentEpisode]
                                  .link,
                              onFullScreen: (_fullscreen) =>
                                  setState(() => fullScreen = _fullscreen),
                            )
                          : Container(),
                      Expanded(
                        child: CustomScrollView(
                          controller: controller,
                          slivers: [
                            SliverToBoxAdapter(
                              child: playerMode
                                  ? Container()
                                  : SerieView(
                                      image: serie.image,
                                      title: serie.title,
                                      type: serie.type,
                                      seasons: serie.seasons.length,
                                    ),
                            ),
                            SliverToBoxAdapter(
                              child: SerieInfo(
                                title: serie.title,
                                story: serie.story,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: BlocProvider(
                                create: (context) => getIt<CatalogueBloc>(),
                                child: BlocBuilder<CatalogueBloc, BlocState>(
                                  buildWhen: (previous, current) =>
                                      current is SeasonState,
                                  builder: (context, state) {
                                    if (state is SeasonState &&
                                        nextSeason < serie.seasons.length)
                                      seasons.add(Season(
                                        title: serie.seasons[nextSeason++]
                                            ['title'],
                                        link: state.season.link,
                                        episodes: state.season.episodes,
                                      ));
                                    return SeasonsLoader(
                                      loadedSeasons: seasons,
                                      currentSeason: nextSeason,
                                      seasonsSchema: serie.seasons,
                                      controller: controller,
                                      onPlay: onPlay,
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
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
    );
  }

  Widget buildDraggable() {
    return DraggableScrollableSheet(
      key: Key(playerMode ? "static" : "dynamic"),
      initialChildSize: playerMode ? 1.0 : 0.5,
      minChildSize: playerMode ? 1 : 0.5,
      expand: false,
      builder: (_, controller) => buildBody(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: buildDraggable(),
    );
  }
}
