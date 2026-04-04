import 'dart:convert';

import 'package:http/http.dart' as http;

/// Minimal OpenRouter chat-completions HTTP client (shared by coach + assessment flows).
class OpenRouterChatClient {
  OpenRouterChatClient({
    required this.apiKey,
    required this.model,
    http.Client? httpClient,
    this.referer = 'https://emvo.app',
    this.appTitle = 'Emvo',
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final String referer;
  final String appTitle;
  final http.Client _http;

  static const baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// [maxTokens] caps completion length so OpenRouter returns faster (less to generate).
  /// Omit for provider default (often slower / verbose).
  Future<String> complete(
    List<Map<String, String>> messages, {
    int? maxTokens,
    double? temperature,
  }) async {
    final uri = Uri.parse(baseUrl);
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
    };
    if (maxTokens != null) {
      body['max_tokens'] = maxTokens;
    }
    if (temperature != null) {
      body['temperature'] = temperature;
    }
    final encoded = jsonEncode(body);

    final response = await _http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': referer,
            'X-Title': appTitle,
          },
          body: encoded,
        )
        .timeout(const Duration(seconds: 90));

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (decoded.containsKey('error')) {
      final err = decoded['error'];
      final msg = err is Map ? err['message']?.toString() : err.toString();
      throw StateError(msg ?? 'OpenRouter error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'OpenRouter HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw StateError('OpenRouter returned no choices');
    }

    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw StateError('OpenRouter returned empty content');
    }
    return content;
  }
}
