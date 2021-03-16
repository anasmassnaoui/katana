import 'package:dio/dio.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:get_it/get_it.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/datasource/egybest_data_source.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:katana/utils/client.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // register home page bloc
  getIt.registerFactory(
    () => CatalogueBloc(egybestRipository: getIt()),
  );

  // register egybest ripository
  getIt.registerLazySingleton(
    () => EgybestRipository(egybestDatasource: getIt()),
  );
  // register egybest data source
  getIt.registerLazySingleton(
    () => EgybestDatasource(client: getIt()),
  );
  // register Client
  final String userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
  getIt.registerLazySingleton(
    () => Client(
      userAgent: userAgent,
      dio: getIt(),
    ),
  );

  // register Dio
  getIt.registerLazySingleton(() => Dio());
}
