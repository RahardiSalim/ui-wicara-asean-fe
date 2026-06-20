import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

final class TtsChunk {
  const TtsChunk({
    required this.audioBytes,
    required this.index,
    required this.total,
  });

  final Uint8List audioBytes;
  final int index;
  final int total;
}

final class SpeechApiException implements Exception {
  const SpeechApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SpeechApiClient {
  SpeechApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<List<TtsChunk>> synthesize({
    required String text,
    required String locale,
    String voice = 'Aoede',
  }) async {
    final response = await _post(
      '/api/speech/tts',
      body: {'text': text, 'locale': locale, 'voice': voice},
      timeout: const Duration(seconds: 75),
    );
    final decoded = _decodeJson(response);
    if (decoded is! List) {
      throw const SpeechApiException('Expected a list of speech chunks.');
    }

    try {
      return decoded.map((value) {
        final item = value as Map<String, dynamic>;
        return TtsChunk(
          audioBytes: base64Decode(item['audio_b64'] as String),
          index: item['chunk_index'] as int,
          total: item['total_chunks'] as int,
        );
      }).toList(growable: false)
        ..sort((left, right) => left.index.compareTo(right.index));
    } on Object catch (error) {
      throw SpeechApiException('Invalid speech response: $error');
    }
  }

  Future<String> transcribe({
    required Uint8List wavBytes,
    required String locale,
  }) async {
    final response = await _post(
      '/api/speech/stt',
      body: {'audio_b64': base64Encode(wavBytes), 'locale': locale},
      timeout: const Duration(seconds: 45),
    );
    final decoded = _decodeJson(response);
    if (decoded is! Map<String, dynamic>) {
      throw const SpeechApiException('Expected a transcription response.');
    }
    final text = decoded['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const SpeechApiException('Transcription response contained no text.');
    }
    return text.trim();
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path);
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SpeechApiException(
          _responseError(response),
          statusCode: response.statusCode,
        );
      }
      return response;
    } on SpeechApiException {
      rethrow;
    } on Object catch (error) {
      throw SpeechApiException('Speech request failed: $error');
    }
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw SpeechApiException('Speech response was not valid JSON: $error');
    }
  }

  String _responseError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {}
    return 'Speech request failed with status ${response.statusCode}.';
  }
}
