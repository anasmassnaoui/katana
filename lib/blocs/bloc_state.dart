part of 'catalogue_bloc.dart';

abstract class BlocState extends Equatable {
  const BlocState();

  @override
  List<Object> get props => [];
}

class LoadingState extends BlocState {}

class InitState extends BlocState {}

class ErrorState extends BlocState {
  final String message;

  ErrorState({
    @required this.message,
  });

  @override
  List<Object> get props => [message];
}

class CatalogueState extends BlocState {
  final Catalogue catalogue;
  final List<Map<String, String>> filters;
  final bool isSearching;
  final String searchValue;

  CatalogueState({
    @required this.catalogue,
    this.filters,
    this.isSearching: false,
    this.searchValue,
  });

  @override
  List<Object> get props => [catalogue, filters, isSearching, searchValue];
}

class MovieState extends BlocState {
  final Movie movie;

  MovieState({
    @required this.movie,
  });

  @override
  List<Object> get props => [movie];
}

class SerieState extends BlocState {
  final Serie serie;

  SerieState({
    @required this.serie,
  });

  @override
  List<Object> get props => [serie];
}
