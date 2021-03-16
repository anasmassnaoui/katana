import 'package:dartz/dartz.dart';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/errors/error.dart';
import 'package:katana/datasource/egybest_data_source.dart';
import 'package:katana/models/movie_model.dart';

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
}
