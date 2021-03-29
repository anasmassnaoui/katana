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

class SerieEvent extends BlocEvent {
  final String link;

  SerieEvent({
    @required this.link,
  });

  @override
  List<Object> get props => [link];
}

class SeasonEvent extends BlocEvent {
  final String link;

  SeasonEvent({
    @required this.link,
  });

  @override
  List<Object> get props => [link];
}

class LoadingEvent extends BlocEvent {}

class ErrorEvent extends BlocEvent {
  final String message;

  ErrorEvent({
    @required this.message,
  });

  @override
  List<Object> get props => [message];
}

class CatalogueEvent extends BlocEvent {
  final List<Cover> covers;
  final List<Map<String, String>> filters;
  final bool isSearching;
  final String searchValue;
  final int page;
  final bool hasReachedMax;

  CatalogueEvent({
    this.covers: const <Cover>[],
    this.filters,
    this.page: 1,
    this.isSearching: false,
    this.searchValue,
    this.hasReachedMax: true,
  });

  @override
  List<Object> get props =>
      [covers, filters, isSearching, searchValue, page, hasReachedMax];
}
