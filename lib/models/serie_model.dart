import 'package:katana/entities/serie.dart';
import 'package:katana/utils/id_parser.dart';
import 'package:meta/meta.dart';

class SerieModel extends Serie {
  SerieModel({
    @required String id,
    @required String title,
    @required String image,
    @required String story,
    @required String type,
    @required String link,
  }) : super(
          id: id,
          title: title,
          image: image,
          story: story,
          type: type,
          link: link,
        );

  factory SerieModel.fromJson(Map<String, dynamic> json) {
    return SerieModel(
        id: getId(json['id']),
        title: json['title'],
        image: json['image'],
        story: json['story'],
        type: json['type'],
        link: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {
      id: id,
      title: title,
      image: image,
      story: story,
      type: type,
      link: link,
    };
  }
}
