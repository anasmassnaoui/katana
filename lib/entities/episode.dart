import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Episode extends Equatable {
  final String id;
  final String title;
  final String image;
  final String duration;
  final String link;

  Episode({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.link,
    this.duration,
  });

  @override
  List<Object> get props => [id, title, image, duration, link];
}
