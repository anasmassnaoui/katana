import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/pages/search_page.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/selector.dart';
import 'package:katana/widgets/Galerie.dart';
import 'package:katana/widgets/label.dart';
import 'package:katana/widgets/loading.dart';
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

  void updateState({
    List<Map<String, String>> filters,
    List<Cover> covers: const [],
    int page: 1,
    bool hasReachedMax: true,
  }) {
    catalogueBloc.add(
      CatalogueEvent(
        covers: covers,
        filters: filters,
        page: page,
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
    bool hasReachedMax: true,
  }) {
    updateState(
      filters: filters,
      covers: oldCovers,
      page: page,
      hasReachedMax: hasReachedMax,
    );
    if (oldCovers.isEmpty) displayLoading();
    catalogueBloc.egybestRipository
        .getTrending(filters: filters, page: page)
        .then(
          (value) => value.fold(
            (error) => displayMessage("Server Error"),
            (catalogue) => updateState(
              covers: oldCovers + catalogue.covers,
              filters: filters,
              page: catalogue.page,
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
        appBar: AppBar(
          centerTitle: true,
          title: Text('Katana'),
          leading: IconButton(
            icon: Icon(CupertinoIcons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            ),
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
                Card(
                  child: Row(
                    children: generateFilterLabels(state.filters),
                  ),
                ),
                Expanded(
                  child: Galerie(
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
