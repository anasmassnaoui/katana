import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/widgets/loading.dart';

class SeriePage extends StatelessWidget {
  final String link;
  final String title;

  SeriePage({
    Key key,
    @required this.link,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () => print('what!!!!!'),
      onDragStart: (details) => print('drag start'),
      onDragEnd: (details, {isClosing}) => print('drag end'),
      enableDrag: true,
      builder: (_) => NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowGlow();
          return true;
        },
        child: SingleChildScrollView(
          //controller: controller,
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
                        create: (context) {
                          print('init');
                          // controller.addListener(() {
                          //   if (!fired &&
                          //       controller.position.pixels >=
                          //           controller.position.maxScrollExtent) {
                          //     fired = !fired;
                          //     print('reach the end');
                          //   }
                          // });
                          return getIt<CatalogueBloc>();
                        },
                        child: BlocBuilder<CatalogueBloc, BlocState>(
                          builder: (context, state) {
                            if (state is InitState) {
                              //BlocProvider.of<CatalogueBloc>(context);
                              // controller.addListener(() {
                              //   if (!fired &&
                              //       controller.position.pixels >=
                              //           controller.position.maxScrollExtent) {
                              //     fired = true;
                              //     print('called');
                              //     // seasonsBloc.add(
                              //     //   SeasonEvent(
                              //     //     link: serie.seasons[currentSeason]
                              //     //         ['link'],
                              //     //   ),
                              //     // );
                              //   }
                              // });

                            }
                            if (state is SeasonState) {
                              final season = state.season;
                              seasons.add(Season(
                                title: serie.seasons[currentSeason++]['title'],
                                link: season.link,
                                episodes: season.episodes,
                              ));
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Text('$index'),
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: seasons.length,
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
