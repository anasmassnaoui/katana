import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/movie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/loads.dart';
import 'package:katana/widgets/loading.dart';
import 'package:katana/widgets/movie_view.dart';
import 'package:katana/widgets/player_with_controlls.dart';
import 'package:katana/widgets/serie_info.dart';
import '../blocs/catalogue_bloc.dart';

class MoviePage extends StatefulWidget {
  final String link;
  final String title;

  const MoviePage({Key key, this.link, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MoviePageState();
}

class MoviePageState extends State<MoviePage> {
  bool fullScreen = false;
  bool playerMode = false;

  void onPlay() => setState(() => playerMode = true);

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
                getIt<CatalogueBloc>()..add(MovieEvent(link: widget.link)),
            child: BlocBuilder<CatalogueBloc, BlocState>(
              builder: (context, state) {
                if (state is MovieState) {
                  Movie movie = state.movie;
                  return Column(
                    children: [
                      playerMode
                          ? PlayerWithControls(
                              title: movie.title,
                              link: movie.link,
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
                                  : MovieView(
                                      image: movie.image,
                                      title: movie.title,
                                      type: movie.type,
                                      duration: movie.duration,
                                      onPlay: () => onPlay(),
                                      onDownload: () =>
                                          onDownload(context, movie.link),
                                    ),
                            ),
                            SliverToBoxAdapter(
                              child: SerieInfo(
                                title: movie.title,
                                story: movie.story,
                              ),
                            ),
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
