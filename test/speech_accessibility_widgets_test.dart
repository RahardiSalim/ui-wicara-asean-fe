import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_accessibility_scope.dart';
import 'package:wicara_mobile/src/core/accessibility/speech_controller.dart';
import 'package:wicara_mobile/src/core/widgets/speech_controls.dart';

import 'support/speech_fakes.dart';

void main() {
  testWidgets('ReadAloudButton has semantics and disables before init', (
    tester,
  ) async {
    final harness = _SpeechHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(
      harness.wrap(
        const ReadAloudButton(textToRead: 'Lesson text', locale: 'en-US'),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Read aloud')),
      containsSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );

    await tester.runAsync(harness.controller.init);
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Read aloud')),
      containsSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
  });

  testWidgets('MicrophoneToggle exposes states and returns text without submit', (
    tester,
  ) async {
    final harness = _SpeechHarness();
    addTearDown(harness.dispose);
    await tester.runAsync(harness.controller.init);
    final textController = TextEditingController();
    addTearDown(textController.dispose);
    var submitCount = 0;

    await tester.pumpWidget(
      harness.wrap(
        Column(
          children: [
            TextField(
              controller: textController,
              onSubmitted: (_) => submitCount++,
            ),
            MicrophoneToggle(
              locale: 'en-US',
              onTranscript: (text) {
                textController.text = text;
              },
            ),
          ],
        ),
      ),
    );

    expect(find.text('Voice input'), findsOneWidget);
    await tester.runAsync(() => tester.tap(find.text('Voice input')));
    await tester.pump();
    expect(find.text('Listening...'), findsOneWidget);

    // Stopping listening drives real async work (stream cancellation and
    // transcription) that fake-async pumping cannot advance, so run it through
    // runAsync before pumping the resulting UI rebuild.
    await tester.runAsync(() => tester.tap(find.text('Listening...')));
    await tester.pumpAndSettle();

    expect(textController.text, 'test transcript');
    expect(submitCount, 0);
    expect(find.text('Voice input'), findsOneWidget);
  });

  testWidgets('SpeechStatusBanner is live only while speech is active', (
    tester,
  ) async {
    final harness = _SpeechHarness()..player.autoComplete = false;
    addTearDown(harness.dispose);
    await tester.runAsync(harness.controller.init);

    await tester.pumpWidget(
      harness.wrap(const SpeechStatusBanner(locale: 'en-US')),
    );
    expect(find.text('Speaking'), findsNothing);

    unawaited(harness.controller.speak('Keep this speech active.'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Speaking'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Speaking')),
      containsSemantics(isLiveRegion: true),
    );

    unawaited(harness.controller.stop());
    await tester.pump();
    await tester.pump();
    expect(find.text('Speaking'), findsNothing);
  });

  testWidgets('StopButton follows speaking, listening, and processing modes', (
    tester,
  ) async {
    final harness = _SpeechHarness()..player.autoComplete = false;
    addTearDown(harness.dispose);
    await tester.runAsync(harness.controller.init);
    await tester.pumpWidget(harness.wrap(const StopButton(locale: 'en-US')));

    expect(find.text('Stop speaking'), findsNothing);

    // speak()/startListening()/stop() reach their target mode within a couple of
    // microtask turns, which plain pumps drain. The non-completing fake playback
    // keeps the controller parked in the speaking mode.
    unawaited(harness.controller.speak('Speaking state.'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Stop speaking'), findsOneWidget);
    unawaited(harness.controller.stop());
    await tester.pump();

    unawaited(harness.controller.startListening());
    await tester.pump();
    await tester.pump();
    expect(find.text('Stop speaking'), findsOneWidget);

    // Gate transcription so the controller parks in the processing mode. The
    // recorder teardown before the gate is real async, so start stopListening
    // inside runAsync and let it advance up to the gated transcription.
    harness.apiClient.transcribeGate = Completer<String>();
    await tester.runAsync(() async {
      unawaited(harness.controller.stopListening(locale: 'en-US'));
      while (harness.controller.mode != SpeechMode.processing ||
          harness.apiClient.transcribeCount == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    await tester.pump();
    expect(harness.controller.mode, SpeechMode.processing);
    expect(find.text('Stop speaking'), findsOneWidget);

    // Stopping mid-processing returns to idle. Run stop() inside runAsync (its
    // recorder teardown is real async) and release the gate so the parked
    // transcription unwinds without leaving a pending timer behind.
    await tester.runAsync(() async {
      await harness.controller.stop();
      harness.apiClient.transcribeGate!.complete('late transcript');
    });
    await tester.pump();
    expect(harness.controller.mode, SpeechMode.idle);
    expect(find.text('Stop speaking'), findsNothing);
  });
}

class _SpeechHarness {
  _SpeechHarness()
    : apiClient = FakeSpeechApiClient(),
      player = FakeAudioPlayer(),
      recorder = FakeAudioRecorder() {
    controller = SpeechController(
      apiClient: apiClient,
      player: player,
      recorder: recorder,
    );
  }

  final FakeSpeechApiClient apiClient;
  final FakeAudioPlayer player;
  final FakeAudioRecorder recorder;
  late final SpeechController controller;

  Widget wrap(Widget child) {
    return SpeechAccessibilityScope(
      notifier: controller,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  void dispose() {
    controller.dispose();
  }
}
