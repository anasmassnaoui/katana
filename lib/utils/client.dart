import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class Client {
  final String userAgent;
  final Dio dio;
  String url = "www.egybest.com";
  Map<String, String> headers = {};

  Client({
    @required this.userAgent,
    @required this.dio,
  }) {
    headers['User-Agent'] = userAgent;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options) async {
        options.headers.addAll(headers);
        options.baseUrl = options.baseUrl.isEmpty
            ? Uri.https(url, '').toString()
            : options.baseUrl;
        print('${options.baseUrl}${options.path}');
        return options;
      },
      onResponse: (res) async {
        if (!headers.containsKey('Cookie'))
          headers['Cookie'] = res.headers['set-cookie']
              .firstWhere((cookie) => cookie.contains('PSSID'))
              .split(';')[0];
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

  Future<Response> get(String path) {
    return dio.get(path);
  }

  Future<Response> post(String path, {Map<String, dynamic> data}) {
    return dio.post(path, data: data);
  }
}
