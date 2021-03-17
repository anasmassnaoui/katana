import 'package:equatable/equatable.dart';
import 'package:katana/entities/cover.dart';

class Catalogue extends Equatable {
  final List<Cover> covers;
  final int page;
  final bool hasReachedMax;

  Catalogue({
    this.covers: const [],
    this.page: 0,
    this.hasReachedMax: true,
  });

  @override
  List<Object> get props => [
        covers,
        page,
        hasReachedMax,
      ];
}
