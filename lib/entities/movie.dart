import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Movie extends Equatable {
  final String id;
  final String title;
  final String image;
  final String story;
  final String type;
  final String duration;
  final String link;

  Movie({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.story,
    @required this.type,
    @required this.duration,
    @required this.link,
  });

  @override
  List<Object> get props => [id, title, image, story, type, duration, link];

  @override
  String toString() {
    return '$id\n$title\n$image\n$story\n$type\n$duration\n$link';
  }
}
