import 'package:katana/entities/catalogue.dart';
import 'package:katana/models/cover_model.dart';
import 'package:meta/meta.dart';

class CatalogueModel extends Catalogue {
  final List<CoverModel> covers;
  final int page;
  final bool hasReachedMax;

  CatalogueModel({
    @required this.covers,
    @required this.page,
    @required this.hasReachedMax,
  });

  factory CatalogueModel.fromJson(Map<String, dynamic> json) {
    return CatalogueModel(
      covers:
          (json['covers'] as List).map((e) => CoverModel.fromJson(e)).toList(),
      page: json['page'],
      hasReachedMax: json['hasReachedMax'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'covers': covers.map((e) => e.toJson()).toList(),
      'page': page,
      'hasReachedMax': hasReachedMax,
    };
  }
}
