import 'package:equatable/equatable.dart';
import 'package:katana/entities/season.dart';
import 'package:meta/meta.dart';

class Serie extends Equatable {
  final String id;
  final String title;
  final String image;
  final String story;
  final String type;
  final String link;
  final List<Map<String, String>> seasons;

  Serie({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.story,
    @required this.type,
    @required this.link,
    @required this.seasons,
  });

  @override
  List<Object> get props => [id, title, image, story, type, link, seasons];
}
