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

    var semantics = tester.getSemantics(find.bySemanticsLabel('Read aloud'));
    expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);

    await harness.controller.init();
    await tester.pump();
    semantics = tester.getSemantics(find.bySemanticsLabel('Read aloud'));
    expect(semantics.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('MicrophoneToggle exposes states and returns text without submit', (
    tester,
  ) async {
    final harness = _SpeechHarness();
    addTearDown(harness.dispose);
    await harness.controller.init();
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
    await tester.tap(find.text('Voice input'));
    await tester.pump();
    expect(find.text('Listening...'), findsOneWidget);

    await tester.tap(find.text('Listening...'));
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
    await harness.controller.init();

    await tester.pumpWidget(
      harness.wrap(const SpeechStatusBanner(locale: 'en-US')),
    );
    expect(find.text('Speaking'), findsNothing);

    unawaited(harness.controller.speak('Keep this speech active.'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Speaking'), findsOneWidget);
    final semantics = tester.getSemantics(
      find.bySemanticsLabel('Speaking').first,
    );
    expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);

    await harness.controller.stop();
    await tester.pump();
    expect(find.text('Speaking'), findsNothing);
  });

  testWidgets('StopButton follows speaking, listening, and processing modes', (
    tester,
  ) async {
    final harness = _SpeechHarness()..player.autoComplete = false;
    addTearDown(harness.dispose);
    await harness.controller.init();
    await tester.pumpWidget(harness.wrap(const StopButton(locale: 'en-US')));

    expect(find.text('Stop speaking'), findsNothing);

    unawaited(harness.controller.speak('Speaking state.'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Stop speaking'), findsOneWidget);
    await harness.controller.stop();
    await tester.pump();

    await harness.controller.startListening();
    await tester.pump();
    expect(find.text('Stop speaking'), findsOneWidget);

    harness.apiClient.transcribeGate = Completer<String>();
    final transcription = harness.controller.stopListening();
    await tester.pump();
    expect(harness.controller.mode, SpeechMode.processing);
    expect(find.text('Stop speaking'), findsOneWidget);

    await harness.controller.stop();
    harness.apiClient.transcribeGate!.complete('late transcript');
    await transcription;
    await tester.pump();
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
