import 'package:katana/entities/episode.dart';
import 'package:katana/utils/id_parser.dart';
import 'package:meta/meta.dart';

class EpisodeModel extends Episode {
  EpisodeModel({
    @required String id,
    @required String title,
    @required String image,
    @required String duration,
    @required String link,
  }) : super(
          id: id,
          title: title,
          image: image,
          duration: duration,
          link: link,
        );
  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: getId(json['id']),
      title: json['title'],
      image: json['image'],
      duration: json['duartion'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'duration': duration,
      'link': link
    };
  }
}
