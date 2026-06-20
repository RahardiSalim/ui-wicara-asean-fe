import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show AppLifecycleState;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import 'speech_api_client.dart';
import 'speech_text_formatter.dart';

enum SpeechMode { idle, speaking, paused, listening, processing, error }

class SpeechController extends ChangeNotifier {
  SpeechController({
    required SpeechApiClient apiClient,
    required AudioPlayer player,
    required AudioRecorder recorder,
  }) : _apiClient = apiClient,
       _player = player,
       _recorder = recorder;

  final SpeechApiClient _apiClient;
  final AudioPlayer _player;
  final AudioRecorder _recorder;

  SpeechMode _mode = SpeechMode.idle;
  String? _errorMessage;
  String? _activeSpeechText;
  double _speechRate = 1.0;
  bool _ttsAvailable = false;
  bool _sttAvailable = false;
  bool _cancelled = false;
  bool _disposed = false;
  int _operationGeneration = 0;
  int? _listeningGeneration;
  Completer<void>? _playbackCancellation;
  StreamSubscription<Uint8List>? _recordingSubscription;
  BytesBuilder? _recordingBytes;

  SpeechMode get mode => _mode;
  String? get sttInterim => null;
  String? get errorMessage => _errorMessage;
  String? get activeSpeechText => _activeSpeechText;
  double get speechRate => _speechRate;
  bool get ttsAvailable => _ttsAvailable;
  bool get sttAvailable => _sttAvailable;

  Future<void> init() async {
    if (_disposed) return;
    _ttsAvailable = true;
    if (kIsWeb) {
      // Browsers may not resolve microphone permission before a user gesture.
      // Keep startup non-blocking and let startStream request it on mic tap.
      _sttAvailable = true;
      _notify();
      return;
    }
    try {
      _sttAvailable = await _recorder.hasPermission();
    } catch (_) {
      _sttAvailable = false;
    }
    _notify();
  }

  Future<void> speak(String rawText, {String locale = 'en-US'}) async {
    if (_disposed || !_ttsAvailable) return;
    final text = SpeechTextFormatter.format(rawText);
    final textChunks = SpeechTextFormatter.chunk(text);
    if (textChunks.isEmpty) return;

    final generation = ++_operationGeneration;
    _cancelled = false;
    _activeSpeechText = rawText;

    try {
      await _stopRecording(discardAudio: true);
      await _player.stop();
      _setMode(SpeechMode.speaking);
      for (final textChunk in textChunks) {
        if (_shouldCancel(generation)) break;
        final audioChunks = await _apiClient.synthesize(
          text: textChunk,
          locale: locale,
        );
        for (final audioChunk in audioChunks) {
          if (_shouldCancel(generation)) break;
          await _playPcmChunk(audioChunk.audioBytes, generation: generation);
        }
      }
      if (!_shouldCancel(generation)) {
        _activeSpeechText = null;
        _setMode(SpeechMode.idle);
      }
    } on Object catch (error) {
      if (generation == _operationGeneration && !_cancelled) {
        _activeSpeechText = null;
        _setError(error.toString());
      }
    }
  }

  Future<void> pause() async {
    if (_disposed || _mode != SpeechMode.speaking) return;
    try {
      await _player.pause();
      _setMode(SpeechMode.paused);
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> resume() async {
    if (_disposed || _mode != SpeechMode.paused) return;
    try {
      unawaited(_player.play());
      _setMode(SpeechMode.speaking);
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    _cancelled = true;
    ++_operationGeneration;
    _activeSpeechText = null;
    _completePlaybackCancellation();
    try {
      await _player.stop();
      await _stopRecording(discardAudio: true);
      _setMode(SpeechMode.idle);
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> setRate(double rate) async {
    if (_disposed) return;
    _speechRate = rate.clamp(0.5, 2.0).toDouble();
    try {
      await _player.setSpeed(_speechRate);
      _notify();
    } on Object catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> startListening() async {
    if (_disposed) return;
    if (!_sttAvailable) {
      _mode = SpeechMode.idle;
      _errorMessage = 'Microphone permission denied.';
      _notify();
      return;
    }

    _cancelled = true;
    final generation = ++_operationGeneration;
    _activeSpeechText = null;
    _completePlaybackCancellation();
    try {
      await _player.stop();
      await _stopRecording(discardAudio: true);
      final bytes = BytesBuilder(copy: false);
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _recordingBytes = bytes;
      _recordingSubscription = stream.listen(bytes.add);
      _listeningGeneration = generation;
      _setMode(SpeechMode.listening);
    } on Object catch (error) {
      _sttAvailable = false;
      _setError(error.toString());
    }
  }

  Future<String?> stopListening({String locale = 'en-US'}) async {
    if (_disposed || _mode != SpeechMode.listening) return null;
    final generation = _listeningGeneration;
    _setMode(SpeechMode.processing);
    try {
      await _recorder.stop();
      await _recordingSubscription?.cancel();
      _recordingSubscription = null;
      final pcmBytes = _recordingBytes?.takeBytes() ?? Uint8List(0);
      _recordingBytes = null;
      if (pcmBytes.isEmpty) {
        throw const SpeechApiException('No microphone audio was captured.');
      }
      final transcript = await _apiClient.transcribe(
        wavBytes: _wrapPcmAsWav(
          pcmBytes,
          sampleRate: 16000,
          channels: 1,
        ),
        locale: locale,
      );
      if (generation == null || generation != _operationGeneration) {
        return null;
      }
      _listeningGeneration = null;
      _setMode(SpeechMode.idle);
      return transcript;
    } on Object catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  void handleAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(stop());
    }
  }

  void handleRouteChange() {
    unawaited(stop());
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cancelled = true;
    ++_operationGeneration;
    _completePlaybackCancellation();
    unawaited(_disposeResources());
    super.dispose();
  }

  Future<void> _playPcmChunk(
    Uint8List pcmBytes, {
    required int generation,
  }) async {
    final wavBytes = _wrapPcmAsWav(
      pcmBytes,
      sampleRate: 24000,
      channels: 1,
    );
    await _player.setAudioSource(BytesAudioSource(wavBytes));
    await _player.setSpeed(_speechRate);
    final completed = _player.processingStateStream.firstWhere(
      (state) => state == ProcessingState.completed,
    );
    final cancellation = Completer<void>();
    _playbackCancellation = cancellation;
    unawaited(_player.play());
    await Future.any<void>([completed, cancellation.future]);
    if (generation == _operationGeneration) {
      _playbackCancellation = null;
    }
  }

  Future<void> _stopRecording({required bool discardAudio}) async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    await _recordingSubscription?.cancel();
    _recordingSubscription = null;
    if (discardAudio) {
      _recordingBytes = null;
      _listeningGeneration = null;
    }
  }

  Future<void> _disposeResources() async {
    try {
      await _player.stop();
      await _recorder.stop();
    } catch (_) {}
    await _recordingSubscription?.cancel();
    await _player.dispose();
    await _recorder.dispose();
  }

  bool _shouldCancel(int generation) {
    return _disposed || _cancelled || generation != _operationGeneration;
  }

  void _completePlaybackCancellation() {
    final cancellation = _playbackCancellation;
    _playbackCancellation = null;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }
  }

  void _setMode(SpeechMode mode) {
    _mode = mode;
    if (mode != SpeechMode.error) {
      _errorMessage = null;
    }
    _notify();
  }

  void _setError(String message) {
    _mode = SpeechMode.error;
    _errorMessage = message;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}

final class BytesAudioSource extends StreamAudioSource {
  BytesAudioSource(this.bytes);

  final Uint8List bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final first = start ?? 0;
    final last = end ?? bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: last - first,
      offset: first,
      stream: Stream.value(bytes.sublist(first, last)),
      contentType: 'audio/wav',
    );
  }
}

Uint8List _wrapPcmAsWav(
  Uint8List pcmBytes, {
  required int sampleRate,
  required int channels,
}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final output = Uint8List(44 + pcmBytes.length);
  final data = ByteData.sublistView(output);

  void ascii(int offset, String value) {
    for (var index = 0; index < value.length; index++) {
      output[offset + index] = value.codeUnitAt(index);
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + pcmBytes.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, byteRate, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, bitsPerSample, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, pcmBytes.length, Endian.little);
  output.setRange(44, output.length, pcmBytes);
  return output;
}
