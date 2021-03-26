import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/movie.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/widgets/loading.dart';

class MoviePage extends StatelessWidget {
  final String link;
  final String title;

  const MoviePage({
    Key key,
    @required this.link,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      builder: (context, controller) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: Scaffold(
          // appBar: AppBar(
          //   title: Text('-'),
          //   centerTitle: true,
          //   leading: IconButton(
          //     icon: Icon(Icons.close),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowGlow();
              return true;
            },
            child: SingleChildScrollView(
              controller: controller,
              child: BlocProvider(
                create: (context) =>
                    getIt<CatalogueBloc>()..add(MovieEvent(link: link)),
                child: BlocBuilder<CatalogueBloc, BlocState>(
                  builder: (context, state) {
                    if (state is MovieState) {
                      Movie movie = state.movie;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    movie.image,
                                    loadingBuilder: (context, child,
                                            loadingProgress) =>
                                        (loadingProgress == null ||
                                                loadingProgress
                                                        .cumulativeBytesLoaded ==
                                                    loadingProgress
                                                        .expectedTotalBytes)
                                            ? child
                                            : AspectRatio(
                                                aspectRatio: 0.8,
                                                child: Loading(),
                                              ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Stack(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
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
                                  ),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8.0, right: 50.0),
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          movie.title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            movie.type,
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
                                            movie.duration,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          )),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              movie.title,
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
                              movie.story,
                              textDirection: movie.story
                                      .contains(RegExp(r'[\u0600-\u06FF]'))
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
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
