import 'dart:async';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/entities/movie.dart';
import 'package:katana/entities/serie.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
    if (event is CatalogueEvent) {
      if (event.currentCovers.isEmpty) yield LoadingState();
      yield (await event.onFetchServer(egybestRipository)).fold(
        (error) => ErrorState(message: 'server error'),
        (catalogue) => CatalogueState(
            catalogue: Catalogue(
          covers: event.currentCovers + catalogue.covers,
          page: catalogue.page,
          hasReachedMax: catalogue.hasReachedMax,
          filters: event.filters,
          isSearching: event.isSearching,
        )),
      );
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
