import 'package:http/http.dart' as http;

/// Adds the client header and, when a token getter is given, the access token. A request
/// rejected with 401 is retried once after refreshing the session.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({
    required this._inner,
    required this._defaultHeaders,
    this._accessToken,
    this._refresh,
  });

  final http.Client _inner;
  final Map<String, String> _defaultHeaders;
  final String? Function()? _accessToken;
  final Future<bool> Function()? _refresh;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final retry = request is http.Request ? _copy(request) : null;
    final response = await _inner.send(_prepare(request));
    if (response.statusCode != 401 || retry == null || _refresh == null) {
      return response;
    }
    if (!await _refresh()) return response;
    await response.stream.drain<void>();
    return _inner.send(_prepare(retry));
  }

  http.BaseRequest _prepare(http.BaseRequest request) {
    request.headers.addAll(_defaultHeaders);
    final token = _accessToken?.call();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    return request;
  }

  static http.Request _copy(http.Request request) =>
      http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;

  @override
  void close() => _inner.close();
}
