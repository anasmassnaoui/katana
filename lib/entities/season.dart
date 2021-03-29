import 'package:equatable/equatable.dart';
import 'package:katana/entities/episode.dart';
import 'package:meta/meta.dart';

class Season extends Equatable {
  final String title;
  final String link;
  final List<Episode> episodes;

  Season({
    @required this.title,
    @required this.link,
    @required this.episodes,
  });

  @override
  List<Object> get props => [title, link, episodes];
}
