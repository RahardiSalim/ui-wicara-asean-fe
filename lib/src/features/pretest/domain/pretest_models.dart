class PretestQuestion {
  const PretestQuestion({
    this.id = '',
    this.packId = '',
    required this.stepLabel,
    required this.topic,
    required this.prompt,
    required this.helper,
    required this.options,
    this.progressCurrent = 1,
    this.progressMax = 10,
  });

  final String id;
  final String packId;
  final String stepLabel;
  final String topic;
  final String prompt;
  final String helper;
  final List<PretestOption> options;
  final int progressCurrent;
  final int progressMax;
}

class PretestOption {
  const PretestOption({
    required this.id,
    required this.label,
    required this.text,
  });

  final String id;
  final String label;
  final String text;
}

class PretestAnswer {
  const PretestAnswer({
    required this.questionId,
    required this.optionId,
    required this.confidence,
    this.typedReasoning = '',
    this.canvasAssetId,
    this.usedCanvas = false,
  });

  final String questionId;
  final String optionId;
  final int confidence;
  final String typedReasoning;
  final String? canvasAssetId;
  final bool usedCanvas;
}

class PretestReasoning {
  const PretestReasoning({
    required this.answer,
    required this.explanation,
    required this.usedCanvas,
  });

  final PretestAnswer answer;
  final String explanation;
  final bool usedCanvas;
}

class KnowledgeState {
  const KnowledgeState({
    required this.skill,
    required this.gapLabel,
    required this.message,
    required this.pathTitle,
    required this.pathMeta,
    required this.pathDescription,
    this.recommendedPath = 'target_from_basics',
    this.pathOptions = const [],
    this.masteryScore,
    this.confidence,
  });

  final String skill;
  final String gapLabel;
  final String message;
  final String pathTitle;
  final String pathMeta;
  final String pathDescription;
  final String recommendedPath;
  final List<String> pathOptions;
  final double? masteryScore;
  final double? confidence;
}

class PretestAnswerResult {
  const PretestAnswerResult({
    required this.completed,
    this.nextQuestion,
    this.diagnosis,
  });

  final bool completed;
  final PretestQuestion? nextQuestion;
  final KnowledgeState? diagnosis;
}
