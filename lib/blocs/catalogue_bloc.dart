import 'dart:async';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/entities/movie.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../entities/catalogue.dart';
import '../entities/catalogue.dart';

part 'bloc_event.dart';
part 'bloc_state.dart';

class CatalogueBloc extends Bloc<BlocEvent, BlocState> {
  // should replace this ripository by switcher riposistory
  EgybestRipository egybestRipository;

  CatalogueBloc({
    @required EgybestRipository egybestRipository,
  }) : super(InitState()) {
    assert(egybestRipository != null);
    this.egybestRipository = egybestRipository;
  }

  @override
  Stream<BlocState> mapEventToState(
    BlocEvent event,
  ) async* {
    if (event is LoadingEvent) yield LoadingState();

    if (event is CatalogueEvent) {
      yield CatalogueState(
          catalogue: Catalogue(
        covers: event.covers,
        page: event.page,
        filters: event.filters,
        hasReachedMax: event.hasReachedMax,
        isSearching: event.isSearching,
        searchValue: event.searchValue,
      ));
      /*if (event.online) {
        //if (event.covers.isEmpty) yield LoadingState();
        yield await egybestRipository
            .getTrending(
              filters: event.filters,
              page: event.page,
              searchValue: event.searchValue,
            )
            .then((result) => result.fold(
                  (error) => ErrorState(message: 'server error'),
                  (catalogue) => CatalogueState(
                      catalogue: Catalogue(
                    covers: event.covers + catalogue.covers,
                    page: catalogue.page,
                    filters: event.filters,
                    hasReachedMax: catalogue.hasReachedMax,
                    isSearching: event.isSearching,
                    searchValue: event.searchValue,
                    loading: false,
                  )),
                ));
      }*/
    }
    if (event is MovieEvent) {
      yield LoadingState();
      yield (await egybestRipository.getMovie(event.link)).fold(
        (error) => ErrorState(message: 'server error'),
        (movie) => MovieState(movie: movie),
      );
    }
  }
}
