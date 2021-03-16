part of 'catalogue_bloc.dart';

abstract class BlocEvent extends Equatable {
  const BlocEvent();

  @override
  List<Object> get props => [];
}

class MovieEvent extends BlocEvent {
  final String link;

  MovieEvent({
    @required this.link,
  });

  @override
  List<Object> get props => [link];
}

class CatalogueEvent extends BlocEvent {
  final List<Cover> currentCovers;
  final Function(EgybestRipository) onFetchServer;
  final List<Map<String, String>> filters;
  final isSearching;

  CatalogueEvent({
    this.currentCovers: const <Cover>[],
    @required this.onFetchServer,
    @required this.filters,
    this.isSearching: false,
  });

  @override
  List<Object> get props =>
      [currentCovers, onFetchServer, filters, isSearching];
}
