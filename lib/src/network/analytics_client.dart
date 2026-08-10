import 'dart:convert';
import 'package:analytics_sdk/analytics_sdk.dart';
import 'package:http/http.dart' as http;

class AnalyticsClient {
  final String baseUrl;
  final String apiKey;

  final http.Client _http;

  AnalyticsClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Future<void> upload(List<AnalyticsEvent> events) async {
    final uri = Uri.parse('${_trimTrailingSlash(baseUrl)}/analytics/event');

    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-Api-Key': apiKey},
      body: jsonEncode({'events': events.map((e) => e.toJson()).toList()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Analytics upload failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  void dispose() => _http.close();

  static String _trimTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }

    return url;
  }
}
