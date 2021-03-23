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
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            controller: controller,
            child: BlocProvider(
              create: (context) =>
                  getIt<CatalogueBloc>()..add(MovieEvent(link: link)),
              child: BlocBuilder<CatalogueBloc, BlocState>(
                builder: (context, state) {
                  if (state is MovieState) {
                    print(state.movie);
                    Movie movie = state.movie;
                    return Column(
                      children: [
                        IntrinsicHeight(
                            child: Row(
                          children: [
                            Expanded(
                              child: Image.network(
                                movie.image,
                              ),
                            ),
                            Expanded(
                                child: Column(
                              children: [
                                ListTile(
                                  title: Text(movie.title),
                                ),
                                ListTile(
                                  title: Text(movie.type),
                                ),
                                ListTile(
                                  title: Text(movie.duration),
                                )
                              ],
                            ))
                          ],
                        )),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Text(movie.story),
                        ),
                      ],
                    );
                  }
                  return Loading();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
