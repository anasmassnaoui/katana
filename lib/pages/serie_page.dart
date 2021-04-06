import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/episode.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/widgets/loading.dart';

import '../blocs/catalogue_bloc.dart';

class SeriePage extends StatelessWidget {
  final String link;
  final String title;
  final ScrollController controller = ScrollController();

  SeriePage({
    Key key,
    @required this.link,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height / 2,
        maxHeight: MediaQuery.of(context).size.height * 90 / 100,
      ),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowGlow();
          return true;
        },
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          controller: controller,
          child: BlocProvider(
            create: (context) =>
                getIt<CatalogueBloc>()..add(SerieEvent(link: link)),
            child: BlocBuilder<CatalogueBloc, BlocState>(
              builder: (context, state) {
                if (state is SerieState) {
                  Serie serie = state.serie;
                  int currentSeason = 0;
                  List<Season> seasons = [];
                  bool fired = false;

                  print(serie.seasons);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IntrinsicHeight(
                          child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(30.0),
                              ),
                              child: Image.network(
                                serie.image,
                                headers: getIt<Client>().headers,
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    (loadingProgress == null ||
                                            loadingProgress
                                                    .cumulativeBytesLoaded ==
                                                loadingProgress
                                                    .expectedTotalBytes)
                                        ? child
                                        : Loading(),
                              ),
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
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          serie.title,
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
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
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
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          serie.type,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          'عدد المواسم : ' +
                                              serie.seasons.length.toString(),
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
                          )),
                        ],
                      )),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          serie.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        child: Text(
                          serie.story,
                          textDirection:
                              serie.story.contains(RegExp(r'[\u0600-\u06FF]'))
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      BlocProvider(
                        create: (context) => getIt<CatalogueBloc>()
                          ..add(SeasonEvent(
                              link: serie.seasons[currentSeason]['link'])),
                        child: BlocBuilder<CatalogueBloc, BlocState>(
                          builder: (context, state) {
                            if (state is InitState) {
                              controller.addListener(() {
                                if (!fired &&
                                    currentSeason < serie.seasons.length &&
                                    controller.position.pixels >=
                                        controller.position.maxScrollExtent -
                                            35) {
                                  fired = true;
                                  BlocProvider.of<CatalogueBloc>(context).add(
                                    SeasonEvent(
                                      link: serie.seasons[currentSeason]
                                          ['link'],
                                    ),
                                  );
                                  print('called');
                                }
                              });
                            }
                            if (state is SeasonState) {
                              final season = state.season;
                              fired = false;
                              seasons.add(Season(
                                title: serie.seasons[currentSeason++]['title'],
                                link: season.link,
                                episodes: season.episodes,
                              ));
                            }
                            return Column(
                              children: [
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          seasons[index].title,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      Container(
                                        height: 200,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          reverse: true,
                                          itemBuilder: (_, _index) =>
                                              EpisodeView(
                                                  episode: seasons[index]
                                                      .episodes[_index]),
                                          itemCount:
                                              seasons[index].episodes.length,
                                        ),
                                      ),
                                    ],
                                  ),
                                  separatorBuilder: (context, index) =>
                                      Divider(),
                                  itemCount: seasons.length,
                                ),
                                currentSeason < serie.seasons.length
                                    ? Container(
                                        padding: EdgeInsets.all(20.0),
                                        child: Loading())
                                    : Container(),
                              ],
                            );
                          },
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
}

class EpisodeView extends StatelessWidget {
  final Episode episode;

  const EpisodeView({
    Key key,
    @required this.episode,
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
            child: Image.network(episode.image),
          ),
          Positioned.fill(
              child: IconButton(
            iconSize: 40,
            icon: Icon(CupertinoIcons.play_fill),
            onPressed: () => null,
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
                  onPressed: () => null,
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
