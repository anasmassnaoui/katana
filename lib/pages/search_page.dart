import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/loads.dart';
import 'package:katana/widgets/Galerie.dart';
import 'package:katana/widgets/loading.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();
  CatalogueBloc catalogueBloc;
  bool fired = false;
  String searchValue;

  void loadCovers({
    List<Cover> covers: const [],
    int page: 1,
    bool hasReachedMax: true,
  }) {
    catalogueBloc.add(
      CatalogueEvent(
        covers: covers,
        page: page,
        hasReachedMax: hasReachedMax,
      ),
    );
  }

  void displayLoading() {
    catalogueBloc.add(LoadingEvent());
  }

  void fetchCovers({
    List<Cover> oldCovers: const [],
    int page: 1,
    bool hasReachedMax: true,
  }) {
    catalogueBloc.egybestRipository
        .search(searchValue: searchValue, page: page)
        .then(
          (value) => value.fold(
            (error) => {},
            (catalogue) => loadCovers(
              covers: oldCovers + catalogue.covers,
              page: catalogue.page,
              hasReachedMax: catalogue.hasReachedMax,
            ),
          ),
        );
  }

  void autoComplete(String searchValue) {
    catalogueBloc.add(AutoCompleteEvent(searchValue: searchValue));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CatalogueBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            onSubmitted: (value) {
              searchValue = value;
              displayLoading();
              fetchCovers();
            },
            onChanged: autoComplete,
            controller: textEditingController,
            cursorHeight: 22,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(borderSide: BorderSide.none),
              suffixIcon: IconButton(
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () => textEditingController.clear(),
              ),
            ),
          ),
        ),
        body: BlocBuilder<CatalogueBloc, BlocState>(
          builder: (context, state) {
            if (state is InitState) {
              catalogueBloc = BlocProvider.of<CatalogueBloc>(context);
            }
            if (state is CatalogueState) {
              fired = false;
              return Galerie(
                catalogue: state.catalogue,
                fetchCovers: ({
                  List<Cover> oldCovers,
                  int page,
                  bool hasReachedMax,
                }) {
                  if (!fired) {
                    fired = true;
                    fetchCovers(
                      oldCovers: oldCovers,
                      page: page,
                      hasReachedMax: hasReachedMax,
                    );
                  }
                },
              );
            }
            if (state is LoadingState) return Loading();
            if (state is AutoCompleteState) {
              return ListView(
                children: state.covers
                    .map((cover) => ListTile(
                          title: Text(cover.title),
                          onTap: () => loadCover(context, cover),
                        ))
                    .toList(),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
