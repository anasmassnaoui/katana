import 'package:katana/entities/episode.dart';
import 'package:katana/entities/season.dart';
import 'package:meta/meta.dart';

class SeasonModel extends Season {
  SeasonModel({
    @required String link,
    @required String title,
    @required List<Episode> episodes,
  }) : super(
          link: link,
          title: title,
          episodes: episodes,
        );

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      title: json['title'],
      link: json['link'],
      episodes: json['episodes'],
    );
  }
}
