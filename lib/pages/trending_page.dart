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
      //return CupertinoActivityIndicator.partiallyRevealed();
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
    updateState(
      filters: filters,
      covers: oldCovers,
      page: page,
      searchValue: searchValue,
      isSearching: isSearching,
      hasReachedMax: hasReachedMax,
    );
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
      filters = filters.toList();
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
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: BlocBuilder<CatalogueBloc, BlocState>(
            buildWhen: (previous, current) => !(current is LoadingState),
            builder: (context, state) {
              if (state is CatalogueState)
                return AppBar(
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
                );
              return AppBar(
                title: Text("Loading..."),
              );
            },
          ),
        ),
        body: BlocBuilder<CatalogueBloc, BlocState>(
          builder: (context, state) {
            if (state is InitState) {
              catalogueBloc = BlocProvider.of<CatalogueBloc>(context);
              fetchCovers();
            }
            if (state is CatalogueState) {
              fired = false;
              return Column(children: [
                Visibility(
                  visible: !state.isSearching,
                  child: Card(
                    child: Row(
                      children: generateFilterLabels(state.filters),
                    ),
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (!state.catalogue.hasReachedMax &&
                          !fired &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 60) {
                        fired = true;
                        fetchCovers(
                          oldCovers: state.catalogue.covers,
                          page: state.catalogue.page,
                          filters: state.filters,
                          searchValue: state.searchValue,
                          isSearching: state.isSearching,
                          hasReachedMax: state.catalogue.hasReachedMax,
                        );
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => GestureDetector(
                                onTap: () {
                                  final cover = state.catalogue.covers[index];
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
                              childCount: state.catalogue.covers.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.7,
                                    crossAxisCount:
                                        (MediaQuery.of(context).size.width /
                                                140)
                                            .round())),
                        SliverToBoxAdapter(
                          child: buildFooter(state),
                        )
                      ],
                    ),
                  ),
                ),
              ]);
            }
            return Loading();
          },
        ),
      ),
    );
  }
}
