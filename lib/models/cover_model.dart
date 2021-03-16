import 'package:katana/entities/cover.dart';

import 'package:meta/meta.dart';

class CoverModel extends Cover {
  CoverModel({
    @required String title,
    @required String image,
    @required String link,
    @required CoverType type,
  }) : super(
          title: title,
          image: image,
          link: link,
          type: type,
        );

  factory CoverModel.fromJson(Map<String, dynamic> json) {
    return CoverModel(
      title: json['title'],
      image: json['image'],
      link: json['link'],
      type: CoverType.values[json['type']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'link': link,
      'type': type.index,
    };
  }
}
