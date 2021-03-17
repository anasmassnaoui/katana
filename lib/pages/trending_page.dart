import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/pages/movie_page.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/utils/is_null.dart';
import 'package:katana/utils/load_page.dart';
import 'package:katana/utils/selector.dart';
import 'package:katana/widgets/label.dart';
import 'package:katana/widgets/loading.dart';
import 'package:katana/widgets/message.dart';
import 'package:katana/utils/filters.dart';

import '../blocs/catalogue_bloc.dart';
import '../widgets/loading.dart';

class TrendingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TrendingPageState();
}

class TrendingPageState extends State<TrendingPage> {
  bool fired = false;
  CatalogueBloc catalogueBloc;
  TextEditingController textEditingController = TextEditingController();

  Widget buildFooter(BlocState state) {
    if (state is ErrorState)
      return Message(message: state.message);
    else if (state is CatalogueState && !state.catalogue.hasReachedMax)
      return Loading(padding: EdgeInsets.symmetric(vertical: 10));
    return null;
  }

  void updateState({
    List<Map<String, String>> filters,
    List<Cover> covers: const [],
    int page: 1,
    String searchValue,
    bool isSearching: false,
    bool hasReachedMax: true,
  }) {
    catalogueBloc.add(
      CatalogueEvent(
        covers: covers,
        filters: filters,
        page: page,
        isSearching: isSearching,
        searchValue: searchValue,
        hasReachedMax: hasReachedMax,
      ),
    );
  }

  void displayLoading() {
    catalogueBloc.add(LoadingEvent());
  }

  void displayMessage(String message) {
    catalogueBloc.add(ErrorEvent(message: message));
  }

  void fetchCovers({
    List<Map<String, String>> filters: const [
      {'الأكثر مشاهدة': 'trending'},
      {'الآن': 'now'},
    ],
    List<Cover> oldCovers: const [],
    int page: 1,
    String searchValue,
    bool isSearching: false,
    bool hasReachedMax: true,
  }) {
    if (oldCovers.isEmpty) displayLoading();
    catalogueBloc.egybestRipository
        .getTrending(
          filters: filters,
          page: page,
          searchValue: searchValue,
        )
        .then(
          (value) => value.fold(
            (error) => displayMessage("Server Error"),
            (catalogue) => updateState(
              covers: oldCovers + catalogue.covers,
              filters: filters,
              page: catalogue.page,
              searchValue: searchValue,
              isSearching: isSearching,
              hasReachedMax: catalogue.hasReachedMax,
            ),
          ),
        );
  }

  void filterCataloge(
    int index,
    Map<String, String> choices,
    List<Map<String, String>> filters,
  ) async {
    final choice = await selectChoice(
        context,
        Future.value(choices.keys
            .where((key) => key != filters[index].keys.first)
            .toList()));
    if (choice == null) return;
    //List<Map<String, String>> filters;
    if (index == 0) {
      filters = [
        {choice: choices[choice]}
      ];
      filterOptions[choices[choice]].forEach((e) {
        final first = e.entries.firstWhere((f) => f.value == '');
        filters.add({
          first.key: first.value,
        });
      });
    } else {
      //filters = filters.toList();
      filters[index] = {choice: choices[choice]};
    }
    fetchCovers(filters: filters);
  }

  List<Widget> generateFilterLabels(List<Map<String, String>> filters) {
    return List.generate(
      filters.length,
      (index) => Expanded(
        child: Label(
          filters[index].keys.first,
          onTap: () => filterCataloge(
            index,
            (index == 0)
                ? filterOptions['types']
                : filterOptions[filters[0].values.first][index - 1],
            filters,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CatalogueBloc>(),
      child: BlocBuilder<CatalogueBloc, BlocState>(
        builder: (context, _state) {
          switch (_state.runtimeType) {
            case InitState:
              catalogueBloc = BlocProvider.of<CatalogueBloc>(context);
              fetchCovers();
              //setScrollListner();
              return Loading();
            case CatalogueState:
              fired = false;
              CatalogueState state = _state;
              //final state = (state as BlocListener);
              ScrollController scrollController = ScrollController();
              scrollController
                ..addListener(() {
                  if (!state.catalogue.hasReachedMax &&
                      !fired &&
                      scrollController.position.pixels >=
                          scrollController.position.maxScrollExtent) {
                    fired = true;
                    fetchCovers(
                      oldCovers: state.catalogue.covers,
                      page: state.catalogue.page,
                      filters: state.filters,
                      searchValue: state.searchValue,
                      isSearching: state.isSearching,
                    );
                  }
                });

              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: !state.isSearching
                      ? Text('Katana')
                      : TextField(
                          autofocus: isNull(state.searchValue),
                          onSubmitted: (value) => fetchCovers(
                            filters: state.filters,
                            searchValue: value,
                            isSearching: true,
                          ),
                          controller: textEditingController
                            ..text = state.searchValue ?? '',
                          decoration: InputDecoration(
                              hintText: 'Search',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              prefixIcon: IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () => fetchCovers(
                                  filters: state.filters,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => updateState(
                                  filters: state.filters,
                                  isSearching: true,
                                ),
                              )),
                        ),
                  leading: !state.isSearching
                      ? IconButton(
                          icon: Icon(CupertinoIcons.search),
                          onPressed: () => updateState(
                                filters: state.filters,
                                isSearching: true,
                              ))
                      : null,
                ),
                body: state is LoadingState
                    ? Loading()
                    : Column(children: [
                        Visibility(
                          visible: !state.isSearching,
                          child: Card(
                            child: Row(
                              children: generateFilterLabels(state.filters),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverGrid.count(
                                crossAxisCount:
                                    (MediaQuery.of(context).size.width / 140)
                                        .round(),
                                childAspectRatio: 0.7,
                                children: List.generate(
                                  state.catalogue.covers.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      final cover =
                                          state.catalogue.covers[index];
                                      switch (cover.type) {
                                        case CoverType.Movie:
                                          loadPage(
                                              context,
                                              MoviePage(
                                                link: cover.link,
                                                title: cover.title,
                                              ));
                                          break;
                                        default:
                                      }
                                    },
                                    child: Card(
                                      child: Image.network(
                                        state.catalogue.covers[index].image,
                                        fit: BoxFit.fill,
                                        headers: getIt<Client>().headers,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: buildFooter(state),
                              )
                            ],
                          ),
                        ),
                      ]),
              );
            default:
              return Loading();
          }
        },
      ),
    );
  }
}
