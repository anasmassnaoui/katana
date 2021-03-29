import 'package:html/parser.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/entities/episode.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/errors/error.dart';
import 'package:katana/models/catalogue_model.dart';
import 'package:katana/models/episode_moidel.dart';
import 'package:katana/models/movie_model.dart';
import 'package:katana/models/season_model.dart';
import 'package:katana/models/serie_model.dart';
import 'package:katana/utils/client.dart';
import 'package:meta/meta.dart';

abstract class EgybestInterface {
  /// Calls the https://egybest.com/trending/:option?output_format=json endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<CatalogueModel> getTrending({
    @required List<Map<String, String>> filters,
    int page: 0,
    String searchValue,
  });

  Future<MovieModel> getMovie(String link);
  Future<SerieModel> getSerie(String link);
  Future<SeasonModel> getSeason(String link);
}

class EgybestDatasource extends EgybestInterface {
  final Client client;

  EgybestDatasource({
    @required this.client,
  });

  String formatFilter(List<Map<String, String>> filters) {
    String filterFormat = '';
    for (int i = 0; i < filters.length; i++) {
      if (i == 0)
        filterFormat = filters[i].values.first + '/';
      else
        filterFormat += filters[i].values.first +
            (filters[i].values.first == '' ||
                    (i + 1 < filters.length &&
                        filters[i + 1].values.first == '') ||
                    i == filters.length - 1
                ? ''
                : '-');
    }
    return filterFormat;
  }

  CoverType selectType(String link) {
    if (link.contains('serie'))
      return CoverType.Serie;
    else if (link.contains('episode')) return CoverType.Episode;
    return CoverType.Movie;
  }

  @override
  Future<CatalogueModel> getTrending({
    @required List<Map<String, String>> filters,
    int page: 0,
    String searchValue,
  }) async {
    try {
      final queryPage = page > 0 ? 'page=$page&' : '';
      final filterFormat = formatFilter(filters);
      final res = await client.get(searchValue != null
          ? '/explore/?q=$searchValue&$queryPage&output_format=json'
          : '/$filterFormat?${queryPage}output_format=json');

      if ((res.data['html'] as String).isEmpty)
        return CatalogueModel(covers: [], page: 1, hasReachedMax: true);
      final parser = parse(res.data['html']);
      return CatalogueModel.fromJson({
        'covers': parser
            .getElementsByClassName('movie')
            .map((e) => {
                  'title': e.getElementsByClassName('title').first.innerHtml,
                  'image':
                      e.getElementsByTagName('img').first.attributes['src'],
                  'link': e.attributes['href'],
                  'type': selectType(e.attributes['href']).index,
                })
            .toList(),
        'hasReachedMax': parser.getElementsByClassName('auto').isEmpty,
        'page': page + 1
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<MovieModel> getMovie(String link) async {
    try {
      final res = await client.get('$link&output_format=json');
      final parser = parse(res.data['html']);
      final tableInfo = parser
          .getElementsByClassName('movieTable')[0]
          .getElementsByTagName('tr');
      final storySection = parser
          .getElementsByClassName('mbox')[2]
          .getElementsByTagName('div')[1];

      return MovieModel.fromJson({
        'id': link,
        'title': tableInfo[0].text,
        'image': parser
            .getElementsByClassName('movie_img')[0]
            .getElementsByTagName('img')[0]
            .attributes['src'],
        'story': storySection.innerHtml.split('<br>').last,
        'type': tableInfo[3].getElementsByTagName('td')[1].text,
        'duration': tableInfo[5].getElementsByTagName('td')[1].text,
        'link': link,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<SerieModel> getSerie(String link) async {
    try {
      final res = await client.get('$link&output_format=json');
      final parser = parse(res.data['html']);
      final tableInfo = parser
          .getElementsByClassName('movieTable')[0]
          .getElementsByTagName('tr');
      final storySection = parser
          .getElementsByClassName('mbox')[2]
          .getElementsByTagName('div')[1];

      return SerieModel.fromJson({
        'id': link,
        'title': tableInfo[0].text,
        'image': parser
            .getElementsByClassName('movie_img')[0]
            .getElementsByTagName('img')[0]
            .attributes['src'],
        'story': storySection.innerHtml.split('<br>').last,
        'type': tableInfo[3].getElementsByTagName('td')[1].text,
        'link': link,
        'seasons': parser
            .getElementsByClassName('mbox')[5]
            .getElementsByClassName('movie')
            .map((season) => {
                  'title': season.getElementsByClassName('title')[0].innerHtml,
                  'link': season.attributes['href'],
                })
            .toList()
            .reversed
            .toList(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<SeasonModel> getSeason(String link) async {
    try {
      final res = await client.get('$link&output_format=json');
      final parser = parse(res.data['html']);
      final episodes = parser
          .getElementsByClassName('mbox')[5]
          .getElementsByClassName('movie');

      return SeasonModel.fromJson({
        'link': link,
        'title': '',
        'episodes': episodes
            .map(
              (episode) => EpisodeModel.fromJson(
                {
                  'id': episode.attributes['href'],
                  'link': episode.attributes['href'],
                  'title': episode.getElementsByClassName('title')[0].innerHtml,
                  'image':
                      episode.getElementsByTagName('img')[0].attributes['src'],
                },
              ),
            )
            .toList(),
      });
    } catch (e) {
      throw ServerException();
    }
  }
}
