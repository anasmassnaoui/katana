import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class Client {
  final String userAgent;
  final Dio dio;
  String url = "www.egybest.com";
  Map<String, String> headers = {};
  Map<String, String> cookie = {};

  Client({
    @required this.userAgent,
    @required this.dio,
  }) {
    headers.addAll({
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }); //userAgent});
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options) async {
        options.headers.addAll(headers);
        options.headers.addAll(
          {
            'Cookie':
                cookie.keys.map((key) => key + '=' + cookie[key]).join('; ')
          },
        );
        options.baseUrl = options.baseUrl.isEmpty
            ? Uri.https(url, '').toString()
            : options.baseUrl;
        print('${options.method} ${options.baseUrl}${options.path}');
        options.headers.forEach((key, value) => print('$key: $value'));
        if (options.method != 'GET') print('\n${options.data}');
        return options;
      },
      onResponse: (res) async {
        if (res.headers.map.containsKey('set-cookie'))
          res.headers['set-cookie']
              .forEach((cookie) => addCookie(cookie.split(';')[0]));
        // if (!headers.containsKey('Cookie'))
        //   headers['Cookie'] = res.headers['set-cookie']
        //       .firstWhere((cookie) => cookie.contains('PSSID'))
        //       .split(';')[0];
        if (res.redirects.isNotEmpty)
          url = res.redirects.first.location.host.isNotEmpty &&
                  res.redirects.first.location.host.contains('egybest')
              ? res.redirects.first.location.host.toString()
              : url;
        if (res.data is Map && (res.data as Map).containsKey('refresh'))
          return await dio.get(res.request.uri.toString());
        return res;
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic> headers}) {
    return dio.get(path, options: Options(headers: headers));
  }

  void addCookie(String cookie) {
    final tokens = cookie.trim().split('=');
    this.cookie[tokens[0]] = tokens[1];
  }

  void removeCookie(String cookie) {
    final tokens = cookie.trim().split('=');
    this.cookie.remove(tokens[0]);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic> headers,
  }) {
    return dio.post(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }
}
