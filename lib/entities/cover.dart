import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum CoverType { Movie, Serie, Episode }

class Cover extends Equatable {
  final String title;
  final String image;
  final String link;
  final CoverType type;

  Cover({
    @required this.title,
    @required this.image,
    @required this.link,
    @required this.type,
  });

  @override
  List<Object> get props => [title, image, link];
}
