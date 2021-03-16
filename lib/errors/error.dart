import 'package:equatable/equatable.dart';

abstract class Error extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerError extends Error {}

class ServerException implements Exception {}
