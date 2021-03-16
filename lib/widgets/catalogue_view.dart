import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/pages/movie_page.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/utils/load_page.dart';
import 'package:katana/utils/selector.dart';
import 'package:katana/widgets/label.dart';
import 'package:katana/widgets/loading.dart';
import 'package:katana/widgets/message.dart';
import 'package:katana/utils/filters.dart';

class CatalogueView extends StatefulWidget {
  final String searchValue;
  final bool isSearching;

  const CatalogueView({
    Key key,
    this.searchValue,
    this.isSearching: false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CatalogueViewState();
}

class CatalogueViewState extends State<CatalogueView> {
  bool fired = false;
  ScrollController scrollController = ScrollController();
  Catalogue catalogue = Catalogue();
  CatalogueBloc catalogueBloc;

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
          searchValue: widget.searchValue,
          isSearching: widget.isSearching,
        );
      }
    });
  }

  void loadCovers({
    List<Cover> covers: const [],
    int page: 1,
    @required List<Map<String, String>> filters,
    String searchValue,
    bool useServer: true,
    bool isSearching: false,
  }) {
    catalogueBloc.add(CatalogueEvent(
      currentCovers: covers,
      filters: filters,
      isSearching: isSearching,
      onFetchServer: (repository) => !useServer
          ? dartz.Right(Catalogue(
              covers: covers,
              filters: filters,
              isSearching: isSearching,
              page: page,
              hasReachedMax: true,
            ))
          : repository.getTrending(
              page: page,
              filters: filters,
              searchValue: searchValue,
            ),
    ));
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
  void didUpdateWidget(covariant CatalogueView oldWidget) {
    if (widget.isSearching && widget.searchValue == null)
      loadCovers(
          filters: catalogue.filters, useServer: false, isSearching: true);
    else if (widget.isSearching && widget.searchValue.isNotEmpty)
      loadCovers(
          filters: catalogue.filters,
          searchValue: widget.searchValue,
          isSearching: true);
    else
      loadCovers(filters: catalogue.filters);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CatalogueBloc>()
        ..add(CatalogueEvent(
          filters: catalogue.filters,
          onFetchServer: (repository) =>
              repository.getTrending(filters: catalogue.filters),
        )),
      child: BlocBuilder<CatalogueBloc, BlocState>(
        builder: (context, state) {
          if (state is InitState) {
            catalogueBloc = BlocProvider.of<CatalogueBloc>(context);
            setScrollListner(context);
          }
          if (state is LoadingState) {
            return Loading();
          }
          if (state is CatalogueState) {
            fired = false;
            catalogue = state.catalogue;
          }
          return Column(children: [
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
                        (MediaQuery.of(context).size.width / 140).round(),
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
          ]);
        },
      ),
    );
  }
}
