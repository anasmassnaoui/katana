import 'package:katana/entities/movie.dart';
import 'package:katana/utils/id_parser.dart';
import 'package:meta/meta.dart';

class MovieModel extends Movie {
  MovieModel({
    @required String id,
    @required String title,
    @required String image,
    @required String story,
    @required String type,
    @required String duration,
    @required String link,
  }) : super(
          id: id,
          title: title,
          image: image,
          story: story,
          type: type,
          duration: duration,
          link: link,
        );

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: getId(json['id']),
      title: json['title'],
      image: json['image'],
      story: json['story'],
      type: json['type'],
      duration: json['duration'],
      link: json['link'],
    );
  }
}
