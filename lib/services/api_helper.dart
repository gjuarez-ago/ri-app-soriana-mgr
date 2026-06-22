import 'dart:convert';
import 'package:ago_app/utils/constants.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Constants.token}',
      };

  static Uri _uri(String path, {String? baseUrl, Map<String, String>? query}) {
    return Uri.https(baseUrl ?? Constants.apiUrl, path, query);
  }

  /// Construye una URL para la API. Mismo orden de argumentos que `Uri.http`,
  /// pero centraliza el esquema (https) en un solo lugar.
  static Uri buildUri(
    String authority, [
    String unencodedPath = '',
    Map<String, dynamic>? queryParameters,
  ]) =>
      Uri.https(authority, unencodedPath, queryParameters);

  static String _decode(http.Response response) =>
      utf8.decode(response.bodyBytes);

  static Never _throwFromStatus(int status, String body, Uri uri) {
    switch (status) {
      case 400:
        throw ApiException(status, 'Solicitud inválida', uri: uri);
      case 401:
        throw ApiException(status, 'No autorizado', uri: uri);
      case 403:
        throw ApiException(status, 'Acceso denegado', uri: uri);
      case 404:
        throw ApiException(status, 'Recurso no encontrado', uri: uri);
      case 500:
        throw ApiException(status, 'Error en el servidor', uri: uri);
      default:
        throw ApiException(status, body, uri: uri);
    }
  }

  static Future<dynamic> get(
    String path, {
    String? baseUrl,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, baseUrl: baseUrl, query: query);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) return jsonDecode(_decode(response));
    _throwFromStatus(response.statusCode, response.body, uri);
  }

  static Future<dynamic> post(
    String path,
    dynamic body, {
    String? baseUrl,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, baseUrl: baseUrl, query: query);
    final response = await http.post(
      uri,
      headers: _headers,
      body: body is String ? body : jsonEncode(body),
    );
    if (response.statusCode == 200) return jsonDecode(_decode(response));
    _throwFromStatus(response.statusCode, response.body, uri);
  }

  static Future<dynamic> put(
    String path,
    dynamic body, {
    String? baseUrl,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, baseUrl: baseUrl, query: query);
    final response = await http.put(
      uri,
      headers: _headers,
      body: body is String ? body : jsonEncode(body),
    );
    if (response.statusCode == 200) return jsonDecode(_decode(response));
    _throwFromStatus(response.statusCode, response.body, uri);
  }

  static Future<dynamic> delete(
    String path, {
    String? baseUrl,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, baseUrl: baseUrl, query: query);
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode == 200) return jsonDecode(_decode(response));
    _throwFromStatus(response.statusCode, response.body, uri);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Uri? uri;

  const ApiException(this.statusCode, this.message, {this.uri});

  @override
  String toString() => 'ApiException($statusCode): $message${uri != null ? ' — $uri' : ''}';
}
