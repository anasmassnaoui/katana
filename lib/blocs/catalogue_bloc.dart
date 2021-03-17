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
    if (event is ErrorEvent) yield ErrorState(message: event.message);
    if (event is CatalogueEvent) {
      yield CatalogueState(
        catalogue: Catalogue(
          covers: event.covers,
          page: event.page,
          hasReachedMax: event.hasReachedMax,
        ),
        filters: event.filters,
        isSearching: event.isSearching,
        searchValue: event.searchValue,
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
