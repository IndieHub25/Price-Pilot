import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';

/// HTTP client wrapper for external API calls.
///
/// Centralizes request construction, header management, timeout handling,
/// and response parsing so that repositories do not deal with raw HTTP.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a GET request and returns the decoded JSON body.
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final response = await _client
          .get(uri, headers: {...ApiConstants.defaultHeaders, ...?headers})
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('GET request failed: $url', originalError: e);
    }
  }

  /// Performs a POST request with a JSON body.
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client
          .post(
            uri,
            headers: {...ApiConstants.defaultHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      return _handleResponse(response);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('POST request failed: $url', originalError: e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    switch (response.statusCode) {
      case ApiConstants.statusBadRequest:
        throw NetworkException('Bad request', statusCode: response.statusCode);
      case ApiConstants.statusUnauthorized:
        throw const AuthException('Authentication required');
      case ApiConstants.statusForbidden:
        throw const AuthException('Access denied');
      case ApiConstants.statusNotFound:
        throw NetworkException(
          'Resource not found',
          statusCode: response.statusCode,
        );
      default:
        throw NetworkException(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  /// Releases underlying HTTP resources.
  void dispose() {
    _client.close();
  }
}
