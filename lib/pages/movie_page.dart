import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) =>
            getIt<CatalogueBloc>()..add(MovieEvent(link: link)),
        child: BlocBuilder<CatalogueBloc, BlocState>(
          builder: (context, state) {
            if (state is MovieState) print(state.movie);
            return Loading();
          },
        ),
      ),
    );
  }
}
