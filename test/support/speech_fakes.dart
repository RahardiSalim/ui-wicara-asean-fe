import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_api_client.dart';

class FakeSpeechApiClient extends SpeechApiClient {
  FakeSpeechApiClient() : super(baseUrl: 'https://speech.test');

  List<TtsChunk> ttsResult = [
    TtsChunk(audioBytes: Uint8List(2), index: 0, total: 1),
  ];
  String transcript = 'test transcript';
  Object? synthesizeError;
  Object? transcribeError;
  Completer<List<TtsChunk>>? synthesizeGate;
  Completer<String>? transcribeGate;
  int synthesizeCount = 0;
  int transcribeCount = 0;
  String? lastLocale;

  @override
  Future<List<TtsChunk>> synthesize({
    required String text,
    required String locale,
    String voice = 'Aoede',
  }) async {
    synthesizeCount++;
    lastLocale = locale;
    if (synthesizeError != null) throw synthesizeError!;
    if (synthesizeGate != null) return synthesizeGate!.future;
    return ttsResult;
  }

  @override
  Future<String> transcribe({
    required Uint8List wavBytes,
    required String locale,
  }) async {
    transcribeCount++;
    lastLocale = locale;
    if (transcribeError != null) throw transcribeError!;
    if (transcribeGate != null) return transcribeGate!.future;
    return transcript;
  }
}

class FakeAudioPlayer extends AudioPlayer {
  final StreamController<ProcessingState> _states =
      StreamController<ProcessingState>.broadcast();

  bool autoComplete = true;
  int setSourceCount = 0;
  int playCount = 0;
  int pauseCount = 0;
  int stopCount = 0;
  int setSpeedCount = 0;
  double lastSpeed = 1;

  @override
  Stream<ProcessingState> get processingStateStream => _states.stream;

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    setSourceCount++;
    return Duration.zero;
  }

  @override
  Future<void> play() async {
    playCount++;
    if (autoComplete) {
      scheduleMicrotask(completePlayback);
    }
  }

  void completePlayback() {
    if (!_states.isClosed) _states.add(ProcessingState.completed);
  }

  @override
  Future<void> pause() async {
    pauseCount++;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> setSpeed(double speed) async {
    setSpeedCount++;
    lastSpeed = speed;
  }

  @override
  Future<void> dispose() async {
    if (!_states.isClosed) await _states.close();
  }
}

class FakeAudioRecorder extends AudioRecorder {
  FakeAudioRecorder({this.permissionGranted = true});

  bool permissionGranted;
  bool recording = false;
  int startCount = 0;
  int stopCount = 0;
  Uint8List recordedPcm = Uint8List.fromList([0, 0, 1, 0]);

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<Stream<Uint8List>> startStream(RecordConfig config) async {
    startCount++;
    recording = true;
    return Stream<Uint8List>.value(recordedPcm);
  }

  @override
  Future<String?> stop() async {
    stopCount++;
    recording = false;
    return null;
  }

  @override
  Future<bool> isRecording() async => recording;

  @override
  Future<void> dispose() async {}
}
