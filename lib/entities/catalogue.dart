import 'package:equatable/equatable.dart';
import 'package:katana/entities/cover.dart';

class Catalogue extends Equatable {
  final List<Cover> covers;
  final int page;
  final bool hasReachedMax;
  final List<Map<String, String>> filters;
  final bool isSearching;

  Catalogue({
    this.covers: const [],
    this.page: 0,
    this.hasReachedMax: true,
    this.filters: const [
      {'الأكثر مشاهدة': 'trending'},
      {'الآن': 'now'},
    ],
    this.isSearching: false,
  });

  @override
  List<Object> get props => [covers, page, hasReachedMax, filters, isSearching];
}
