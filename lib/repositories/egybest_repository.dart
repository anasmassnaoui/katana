import 'package:dartz/dartz.dart';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/errors/error.dart';
import 'package:katana/datasource/egybest_data_source.dart';
import 'package:katana/models/movie_model.dart';
import 'package:katana/models/quality.dart';
import 'package:katana/models/season_model.dart';
import 'package:katana/models/serie_model.dart';

import 'package:meta/meta.dart';

class EgybestRipository {
  final EgybestDatasource egybestDatasource;
  EgybestRipository({
    @required this.egybestDatasource,
  });

  Future<Either<Error, Catalogue>> getTrending({
    @required List<Map<String, String>> filters,
    int page: 1,
    String searchValue,
  }) async {
    try {
      return Right(await egybestDatasource.getTrending(
          filters: filters, page: page, searchValue: searchValue));
    } on ServerException {
      return Left(ServerError());
    }
  }

  Future<Either<Error, MovieModel>> getMovie(String link) async {
    try {
      return Right(await egybestDatasource.getMovie(link));
    } on ServerException {
      return Left(ServerError());
    }
  }

  Future<Either<Error, SerieModel>> getSerie(String link) async {
    try {
      return Right(await egybestDatasource.getSerie(link));
    } on ServerException {
      return Left(ServerError());
    }
  }

  Future<Either<Error, SeasonModel>> getSeason(String link) async {
    try {
      return Right(await egybestDatasource.getSeason(link));
    } on ServerException {
      return Left(ServerError());
    }
  }

  Future<List<Quality>> getVideoQualities(String link) {
    return egybestDatasource.getVideoQualities(link);
  }

  Future<String> getDirectLink(String link) {
    return egybestDatasource.getDirectLink(link);
  }
}
