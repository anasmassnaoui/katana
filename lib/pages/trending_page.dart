import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/catalogue.dart';
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
import '../blocs/catalogue_bloc.dart';
import '../entities/catalogue.dart';
import '../widgets/loading.dart';

class TrendingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TrendingPageState();
}

class TrendingPageState extends State<TrendingPage> {
  bool fired = false;
  ScrollController scrollController = ScrollController();
  Catalogue catalogue = Catalogue();
  CatalogueBloc catalogueBloc;
  TextEditingController textEditingController = TextEditingController();

  Widget buildFooter(BlocState state) {
    if (state is ErrorState)
      return Message(message: state.message);
    else if (state is CatalogueState && !catalogue.hasReachedMax)
      return Loading(padding: EdgeInsets.symmetric(vertical: 10));
    return null;
  }

  void setScrollListner(BuildContext context) {
    scrollController.addListener(() {
      if (!catalogue.hasReachedMax &&
          !fired &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent) {
        fired = true;
        loadCovers(
          covers: catalogue.covers,
          page: catalogue.page,
          filters: catalogue.filters,
          searchValue: catalogue.searchValue,
          isSearching: catalogue.isSearching,
        );
      }
    });
  }

  void loadCovers({
    @required List<Map<String, String>> filters,
    List<Cover> covers: const [],
    int page: 1,
    String searchValue,
    bool isSearching: false,
    bool online: true,
    bool hasReachedMax: true,
  }) {
    /*catalogueBloc.add(CatalogueEvent(
      covers: covers,
      filters: filters,
      isSearching: isSearching,
      searchValue: searchValue,
      page: page,
      hasReachedMax: hasReachedMax,
    ));*/

    catalogueBloc.egybestRipository
        .getTrending(filters: filters, page: page, searchValue: searchValue)
        .then((value) => value.fold((error) => null, (catalogue) => null));
  }

  void filterCataloge(int index, Map<String, String> choices) async {
    final choice = await selectChoice(
        context,
        Future.value(choices.keys
            .where((key) => key != catalogue.filters[index].keys.first)
            .toList()));
    if (choice == null) return;
    List<Map<String, String>> filters;
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
      filters = catalogue.filters.toList();
      filters[index] = {choice: choices[choice]};
    }
    loadCovers(filters: filters);
  }

  List<Widget> generateFilterLabels() {
    return List.generate(
      catalogue.filters.length,
      (index) => Expanded(
        child: Label(
          catalogue.filters[index].keys.first,
          onTap: () => filterCataloge(
              index,
              (index == 0)
                  ? filterOptions['types']
                  : filterOptions[catalogue.filters[0].values.first]
                      [index - 1]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CatalogueBloc>()
        ..add(CatalogueEvent(
          filters: catalogue.filters,
        )),
      child: BlocBuilder<CatalogueBloc, BlocState>(
        builder: (context, state) {
          if (state is InitState) {
            catalogueBloc = BlocProvider.of<CatalogueBloc>(context);
            setScrollListner(context);
          }
          if (state is CatalogueState) {
            fired = false;
            catalogue = state.catalogue;
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: !catalogue.isSearching
                  ? Text('Katana')
                  : TextField(
                      autofocus: isNull(catalogue.searchValue),
                      onSubmitted: (value) => loadCovers(
                        filters: catalogue.filters,
                        searchValue: value,
                        isSearching: true,
                      ),
                      controller: textEditingController
                        ..text = catalogue.searchValue ?? '',
                      decoration: InputDecoration(
                          hintText: 'Search',
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => loadCovers(
                              filters: catalogue.filters,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => loadCovers(
                              filters: catalogue.filters,
                              isSearching: true,
                              online: false,
                              hasReachedMax: true,
                            ),
                          )),
                    ),
              leading: !catalogue.isSearching
                  ? IconButton(
                      icon: Icon(CupertinoIcons.search),
                      onPressed: () => loadCovers(
                            filters: catalogue.filters,
                            isSearching: true,
                            online: false,
                            hasReachedMax: true,
                          ))
                  : null,
            ),
            body: catalogue.loading
                ? Loading()
                : Column(children: [
                    Visibility(
                      visible: !catalogue.isSearching,
                      child: Card(
                        child: Row(
                          children: generateFilterLabels(),
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
                              catalogue.covers.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  final cover = catalogue.covers[index];
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
                                    catalogue.covers[index].image,
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
        },
      ),
    );
  }
}
