import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_api_client.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_controller.dart';

import 'support/speech_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSpeechApiClient apiClient;
  late FakeAudioPlayer player;
  late FakeAudioRecorder recorder;
  late SpeechController controller;

  setUp(() {
    apiClient = FakeSpeechApiClient();
    player = FakeAudioPlayer();
    recorder = FakeAudioRecorder();
    controller = SpeechController(
      apiClient: apiClient,
      player: player,
      recorder: recorder,
    );
    addTearDown(controller.dispose);
  });

  test('transitions idle to speaking to idle', () async {
    final modes = <SpeechMode>[];
    controller.addListener(() => modes.add(controller.mode));
    await controller.init();

    await controller.speak('A short lesson.', locale: 'en-US');

    expect(modes, containsAllInOrder([SpeechMode.speaking, SpeechMode.idle]));
    expect(controller.mode, SpeechMode.idle);
    expect(player.playCount, 1);
  });

  test('transitions listening to processing and returns transcript', () async {
    final modes = <SpeechMode>[];
    controller.addListener(() => modes.add(controller.mode));
    await controller.init();

    await controller.startListening();
    await Future<void>.delayed(Duration.zero);
    final transcript = await controller.stopListening(locale: 'id-ID');

    expect(transcript, 'test transcript');
    expect(
      modes,
      containsAllInOrder([
        SpeechMode.listening,
        SpeechMode.processing,
        SpeechMode.idle,
      ]),
    );
    expect(apiClient.lastLocale, 'id-ID');
  });

  test('speaking and listening are mutually exclusive', () async {
    await controller.init();
    recorder.recording = true;

    await controller.speak('Stop recording before speaking.');

    expect(recorder.stopCount, greaterThan(0));
    final stopsBeforeListening = player.stopCount;

    await controller.startListening();

    expect(player.stopCount, greaterThan(stopsBeforeListening));
    expect(controller.mode, SpeechMode.listening);
  });

  test('stop cancels an in-flight TTS chunk loop', () async {
    await controller.init();
    final gate = Completer<List<TtsChunk>>();
    apiClient.synthesizeGate = gate;
    final speaking = controller.speak(
      '${List.filled(120, 'first sentence words').join(' ')}. '
      '${List.filled(120, 'second sentence words').join(' ')}.',
    );
    await Future<void>.delayed(Duration.zero);

    expect(apiClient.synthesizeCount, 1);
    await controller.stop();
    gate.complete(apiClient.ttsResult);
    await speaking;

    expect(apiClient.synthesizeCount, 1);
    expect(player.playCount, 0);
    expect(controller.mode, SpeechMode.idle);
  });

  test('permission denial leaves STT unavailable without throwing', () async {
    recorder.permissionGranted = false;

    await controller.init();
    await controller.startListening();

    expect(controller.sttAvailable, isFalse);
    expect(controller.mode, SpeechMode.idle);
    expect(controller.errorMessage, isNotNull);
    expect(recorder.startCount, 0);
  });

  test('API errors become controller error state', () async {
    apiClient.synthesizeError = const SpeechApiException('service failed');
    await controller.init();

    await expectLater(controller.speak('Read this.'), completes);

    expect(controller.mode, SpeechMode.error);
    expect(controller.errorMessage, contains('service failed'));
  });

  test('setRate clamps values to the supported range', () async {
    await controller.init();

    await controller.setRate(0.1);
    expect(controller.speechRate, 0.5);
    expect(player.lastSpeed, 0.5);

    await controller.setRate(3.5);
    expect(controller.speechRate, 2.0);
    expect(player.lastSpeed, 2.0);
  });
}
