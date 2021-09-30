import 'dart:convert';

import 'package:html/parser.dart';
import 'package:interactive_webview/interactive_webview.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/errors/error.dart';
import 'package:katana/models/catalogue_model.dart';
import 'package:katana/models/episode_moidel.dart';
import 'package:katana/models/movie_model.dart';
import 'package:katana/models/quality.dart';
import 'package:katana/models/season_model.dart';
import 'package:katana/models/serie_model.dart';
import 'package:katana/utils/client.dart';
import 'package:meta/meta.dart';

abstract class EgybestInterface {
  /// Calls the https://egybest.com/trending/:option?output_format=json endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<CatalogueModel> getTrending(
      {@required List<Map<String, String>> filters, int page: 0});
  Future<CatalogueModel> search(String searchValue, {int page: 0});
  Future<MovieModel> getMovie(String link);
  Future<SerieModel> getSerie(String link);
  Future<SeasonModel> getSeason(String link);
  Future<List<Quality>> getVideoQualities(String link);
  Future<String> getDirectLink(String link);
  Future<List<Cover>> autoComplete(String searchValue);
}

class EgybestDatasource extends EgybestInterface {
  final Client client;
  final InteractiveWebView webView;

  EgybestDatasource({
    @required this.client,
    @required this.webView,
  });

  // void _setupWebView() async {
  //   webView.loadHTML(
  //     await rootBundle.loadString(
  //       "lib/utils/decoder.html",
  //       cache: false,
  //     ),
  //     baseUrl: 'http://127.0.0.1/',
  //   );
  // }

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
    else if (link.contains('episode'))
      return CoverType.Episode;
    else
      return CoverType.Movie;
  }

  @override
  Future<CatalogueModel> getTrending({
    @required List<Map<String, String>> filters,
    int page: 0,
  }) async {
    try {
      final queryPage = page > 0 ? 'page=$page&' : '';
      final filterFormat = formatFilter(filters);
      final res =
          await client.get('/$filterFormat?${queryPage}output_format=json');

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
            .toList()
            .reversed
            .toList(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<Quality>> getVideoQualities(String link) async {
    print("GET $link");
    try {
      final res = await client.get('$link');
      //await validateAd(res.data, 1);
      //final res = await client.get('$link&output_format=json');
      //final parser = parse(res.data['html']);
      final parser = parse(res.data);
      return parser
          .getElementsByClassName('dls_table')[0]
          .children[1]
          .getElementsByTagName('tr')
          .map((element) {
        final tds = element.getElementsByTagName('td');
        return Quality(tds[1].text.split('<i')[0],
            tds[3].children[0].attributes['data-url']);
      }).toList();
    } catch (e) {
      print(e);
      throw ServerException();
    }
  }

  Future<void> validateAd(String html, int phase) async {
    webView.loadHTML(
      html,
      baseUrl: "http://127.0.0.1/",
    );
    print("loaded!");
    await Future.delayed(Duration(seconds: 2));
    print("eval!");
    webView.evalJavascript('''
            window.message = {};

            window.test = RegExp.prototype.test
            window._test = function(match) {
                if (this == '/android|ios|mobile/i') return false;
                if (this == '/ipad|ipod|iphone|ios/i') return true;
                RegExp.prototype.test = window.test
                const res = this.test(match)
                RegExp.prototype.test = window._test
                return res;
            }
            RegExp.prototype.test = window._test

            const nativeCommunicator =
              typeof webkit !== "undefined"
                ? webkit.messageHandlers.native
                : window.native;

            window.XMLHttpRequest = class {
              UNSENT = 0;
              OPENED = 1;
              HEADERS_RECEIVED = 2;
              LOADING = 3;
              DONE = 4;
              readyState = 1;
              onreadystatechange = function () { };
              responseText = "";
              responseXML = "";
              status = null;
              statusText = null;
              setRequestHeader = function (header, value) { };
              abort = function () { }

              open(method, url, async) {
                message.postUrl = url
                this.onreadystatechange();
              }

              send(data) {
                message.postData = data;
                nativeCommunicator.postMessage(JSON.stringify(message));
              }
            }

            window.open = (url) => {
              message.adsUrl = url
              class W {
                constructor() {
                  setTimeout(this.onload, 1000)
                }
              }
              return new W();
            }

            document.body.click()
      ''');
    final data = (await webView.didReceiveMessage.first).data;
    print(data);
    // await Future.delayed(Duration(hours: 1));
    final postUrl = data['postUrl'];
    final adsUrl = data['adsUrl'];
    final postData = (data['postData'] as String); //.split('=');
    // webView.evalJavascript('''
    //   nativeCommunicator.postMessage(document.cookie);
    // ''');
    // final cookies = (await webView.didReceiveMessage.first).data as String;
    // cookies.split(';').forEach((cookie) => client.addCookie(cookie));
    // print(postData);
    final res = await client.get('$adsUrl').catchError((e) {});
    final start = DateTime.now().millisecondsSinceEpoch;
    if (phase == 1) {
      String text = (res.data as String)
          .replaceAll("<script>", "")
          .replaceAll("</script>", "");
      webView.loadHTML(
        '''
      <html>
      <script>
      const nativeCommunicator =
      typeof webkit !== "undefined"
        ? webkit.messageHandlers.native
        : window.native;
      eval = (expr) => nativeCommunicator.postMessage(expr);
      $text
      </script>
      </html>
    ''',
        baseUrl: "http://127.0.0.1/",
      );
      final expr = (await webView.didReceiveMessage.first).data;
      final cookie = expr.split('"')[1].split(';')[0];
      if ((cookie as String).contains('=')) client.addCookie(cookie);
      print(cookie);
    }
    final end = DateTime.now().millisecondsSinceEpoch;
    await Future.delayed(Duration(milliseconds: 500 - (end - start)));
    await client.post('$postUrl', data: postData, headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    }).catchError((e) {});
    print(end - start);
  }

  @override
  Future<String> getDirectLink(String link) async {
    final res = await client.get('$link', headers: {
      'Referer': 'https://${client.url}/movie/dune-2021/?ref=trends-p1',
    });
    print(res.data);
    final parser = parse(res.data);
    final download = parser.getElementsByClassName('bigbutton');
    if (download.isEmpty) {
      print("BREAK");
      //await Future.delayed(Duration(hours: 1));
      await validateAd(res.data, 1);
      return getDirectLink(link);
    }
    final downloadLink = download[0].attributes['href'];
    if (downloadLink == null) {
      print("PHASE 2");
      await validateAd(res.data, 2);
      return getDirectLink(res.redirects.isNotEmpty
          ? res.redirects.first.location.toString()
          : link);
    } else {
      print("PHASE 3");
      return downloadLink;
    }
  }

  @override
  Future<CatalogueModel> search(String searchValue, {int page: 0}) async {
    try {
      final queryPage = page > 0 ? 'page=$page&' : '';
      final res = await client
          .get('/explore/?q=$searchValue&$queryPage&output_format=json');

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

  Future<List<Cover>> autoComplete(String searchValue) async {
    try {
      final res = await client.get('/autoComplete.php?q=$searchValue');
      final data = jsonDecode(res.data);
      return List<Map<String, dynamic>>.from(data[searchValue])
          .map((cover) => Cover(
              image: '',
              title: cover['t'],
              link: '/' + cover['u'] + '/?ref=home-trends',
              type: selectType(cover['u'])))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
