import 'package:flutter/widgets.dart';

import 'speech_controller.dart';

class SpeechAccessibilityScope extends InheritedNotifier<SpeechController> {
  const SpeechAccessibilityScope({
    required SpeechController notifier,
    required Widget child,
    super.key,
  }) : super(notifier: notifier, child: child);

  static SpeechController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError(
        'SpeechAccessibilityScope.of() called without a scope ancestor.',
      );
    }
    return controller;
  }

  static SpeechController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SpeechAccessibilityScope>()
        ?.notifier;
  }
}
