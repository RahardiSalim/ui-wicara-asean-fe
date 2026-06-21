import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/onboarding/domain/onboarding_copy.dart';
import '../accessibility/speech_accessibility_scope.dart';
import '../accessibility/speech_controller.dart';
import '../theme/wicara_colors.dart';

class ReadAloudButton extends StatelessWidget {
  const ReadAloudButton({
    required this.textToRead,
    required this.locale,
    super.key,
  });

  final String textToRead;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final copy = OnboardingCopy.forLanguage(locale);
    final controller = SpeechAccessibilityScope.maybeOf(context);
    if (controller == null) {
      return Semantics(
        label: copy.speechReadAloud,
        hint: copy.speechServiceUnavailable,
        button: true,
        enabled: false,
        child: ExcludeSemantics(
          child: TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.volume_off_outlined, size: 19),
            label: Text(copy.speechReadAloud),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isActiveText = controller.activeSpeechText == textToRead;
        final paused = isActiveText && controller.mode == SpeechMode.paused;
        final speaking =
            isActiveText && controller.mode == SpeechMode.speaking;
        final label = paused
            ? copy.speechResume
            : speaking
            ? copy.speechPause
            : copy.speechReadAloud;
        final icon = paused
            ? Icons.play_arrow_rounded
            : speaking
            ? Icons.pause_rounded
            : Icons.volume_up_outlined;
        final enabled = controller.ttsAvailable && textToRead.trim().isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EscapeToStop(
              controller: controller,
              child: Semantics(
                label: label,
                hint: copy.speechReadAloudHint,
                button: true,
                enabled: enabled,
                toggled: speaking || paused,
                child: ExcludeSemantics(
                  child: TextButton.icon(
                    onPressed: enabled
                        ? () {
                            if (speaking) {
                              controller.pause();
                            } else if (paused) {
                              controller.resume();
                            } else {
                              controller.speak(textToRead, locale: locale);
                            }
                          }
                        : null,
                    icon: Icon(icon, size: 19),
                    label: Text(label),
                  ),
                ),
              ),
            ),
            if (speaking || paused) ...[
              StopButton(locale: locale),
              SpeedSelector(locale: locale),
            ],
          ],
        );
      },
    );
  }
}

class StopButton extends StatelessWidget {
  const StopButton({this.locale = 'en-US', super.key});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final controller = SpeechAccessibilityScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();
    final copy = OnboardingCopy.forLanguage(locale);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visible = controller.mode == SpeechMode.speaking ||
            controller.mode == SpeechMode.paused ||
            controller.mode == SpeechMode.listening ||
            controller.mode == SpeechMode.processing;
        if (!visible) return const SizedBox.shrink();
        return Semantics(
          label: copy.speechStop,
          hint: copy.speechStopHint,
          button: true,
          enabled: true,
          child: ExcludeSemantics(
            child: TextButton.icon(
              onPressed: controller.stop,
              icon: const Icon(Icons.stop_circle_outlined, size: 19),
              label: Text(copy.speechStop),
            ),
          ),
        );
      },
    );
  }
}

class SpeedSelector extends StatelessWidget {
  const SpeedSelector({this.locale = 'en-US', super.key});

  final String locale;
  static const _rates = <double>[0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final copy = OnboardingCopy.forLanguage(locale);
    final controller = SpeechAccessibilityScope.maybeOf(context);
    if (controller == null) {
      return Semantics(
        label: copy.speechSpeed,
        value: copy.speechSpeedValue(1),
        enabled: false,
        child: SegmentedButton<double>(
          segments: const [
            ButtonSegment<double>(value: 1.0, label: Text('1x')),
          ],
          selected: {1.0},
          onSelectionChanged: null,
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Semantics(
          label: copy.speechSpeed,
          value: copy.speechSpeedValue(controller.speechRate),
          liveRegion: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<double>(
              segments: [
                for (final rate in _rates)
                  ButtonSegment<double>(
                    value: rate,
                    label: Text('${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 2)}×'),
                  ),
              ],
              selected: {controller.speechRate},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                controller.setRate(selection.first);
              },
            ),
          ),
        );
      },
    );
  }
}

class MicrophoneToggle extends StatelessWidget {
  const MicrophoneToggle({
    required this.onTranscript,
    this.locale = 'en-US',
    super.key,
  });

  final ValueChanged<String> onTranscript;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final copy = OnboardingCopy.forLanguage(locale);
    final controller = SpeechAccessibilityScope.maybeOf(context);
    if (controller == null) {
      return Semantics(
        label: copy.speechVoiceInput,
        hint: copy.speechServiceUnavailable,
        button: true,
        enabled: false,
        child: ExcludeSemantics(
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.mic_off_outlined, size: 19),
            label: Text(copy.speechVoiceInput),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final listening = controller.mode == SpeechMode.listening;
        final processing = controller.mode == SpeechMode.processing;
        final hasError = controller.mode == SpeechMode.error;
        final enabled = controller.sttAvailable && !processing;
        final (icon, label, color) = switch (controller.mode) {
          SpeechMode.listening => (
            Icons.mic_rounded,
            copy.speechListening,
            WicaraColors.accentCoral,
          ),
          SpeechMode.processing => (
            Icons.hourglass_top_rounded,
            copy.speechProcessing,
            WicaraColors.primaryDeep,
          ),
          SpeechMode.error => (
            Icons.warning_amber_rounded,
            controller.sttAvailable
                ? copy.speechError
                : copy.speechMicPermissionDenied,
            WicaraColors.accentCoral,
          ),
          _ => (
            Icons.mic_none_rounded,
            copy.speechVoiceInput,
            WicaraColors.secondaryDeep,
          ),
        };

        return _EscapeToStop(
          controller: controller,
          child: Semantics(
            label: label,
            hint: controller.sttAvailable
                ? copy.speechVoiceInputHint
                : copy.speechMicPermissionInstructions,
            button: true,
            enabled: enabled || listening,
            toggled: listening,
            liveRegion: listening || processing || hasError,
            child: ExcludeSemantics(
              child: OutlinedButton.icon(
                onPressed: enabled || listening
                    ? () async {
                        if (listening) {
                          final transcript = await controller.stopListening(
                            locale: locale,
                          );
                          if (transcript != null && transcript.isNotEmpty) {
                            onTranscript(transcript);
                          }
                        } else {
                          await controller.startListening();
                        }
                      }
                    : null,
                icon: processing
                    ? SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : listening
                    ? _PulsingMicIcon(color: color)
                    : Icon(icon, color: color, size: 19),
                label: Text(label),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon({required this.color});

  final Color color;

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.88,
    upperBound: 1.12,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Icon(Icons.mic_rounded, color: widget.color, size: 19),
    );
  }
}

class SpeechStatusBanner extends StatefulWidget {
  const SpeechStatusBanner({this.locale = 'en-US', super.key});

  final String locale;

  @override
  State<SpeechStatusBanner> createState() => _SpeechStatusBannerState();
}

class _SpeechStatusBannerState extends State<SpeechStatusBanner> {
  DateTime? _lastAnnouncement;
  SpeechMode? _announcedMode;

  @override
  Widget build(BuildContext context) {
    final controller = SpeechAccessibilityScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();
    final copy = OnboardingCopy.forLanguage(widget.locale);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.mode == SpeechMode.idle) {
          return const SizedBox.shrink();
        }
        final now = DateTime.now();
        final mayAnnounce = _announcedMode != controller.mode &&
            (_lastAnnouncement == null ||
                now.difference(_lastAnnouncement!) >= const Duration(seconds: 2));
        if (mayAnnounce) {
          _announcedMode = controller.mode;
          _lastAnnouncement = now;
        }
        final status = _statusLabel(controller, copy);
        return Semantics(
          liveRegion: mayAnnounce,
          label: status,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: WicaraColors.speechBlue,
            child: Row(
              children: [
                Icon(_statusIcon(controller.mode), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StopButton(locale: widget.locale),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(SpeechController controller, OnboardingCopy copy) {
    return switch (controller.mode) {
      SpeechMode.speaking => copy.speechSpeaking,
      SpeechMode.paused => copy.speechPaused,
      SpeechMode.listening => copy.speechListening,
      SpeechMode.processing => copy.speechProcessing,
      SpeechMode.error => controller.sttAvailable
          ? copy.speechError
          : copy.speechMicPermissionDenied,
      SpeechMode.idle => '',
    };
  }

  IconData _statusIcon(SpeechMode mode) {
    return switch (mode) {
      SpeechMode.speaking => Icons.volume_up_rounded,
      SpeechMode.paused => Icons.pause_circle_outline_rounded,
      SpeechMode.listening => Icons.mic_rounded,
      SpeechMode.processing => Icons.hourglass_top_rounded,
      SpeechMode.error => Icons.warning_amber_rounded,
      SpeechMode.idle => Icons.check_circle_outline_rounded,
    };
  }
}

class _EscapeToStop extends StatelessWidget {
  const _EscapeToStop({required this.controller, required this.child});

  final SpeechController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): controller.stop,
      },
      child: Focus(child: child),
    );
  }
}
