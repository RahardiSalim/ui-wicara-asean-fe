import '../domain/pretest_models.dart';
import '../domain/pretest_repository.dart';

class MockPretestRepository implements PretestRepository {
  const MockPretestRepository({this.delay = const Duration(milliseconds: 450)});

  final Duration delay;

  @override
  Future<void> submitAnswer(PretestAnswer answer) async {
    await Future<void>.delayed(delay);

    if (answer.optionId.isEmpty) {
      throw const PretestException('Choose an answer before continuing.');
    }
  }

  @override
  Future<KnowledgeState> submitReasoning(PretestReasoning reasoning) async {
    await Future<void>.delayed(delay);

    if (reasoning.explanation.trim().isEmpty && !reasoning.usedCanvas) {
      throw const PretestException('Share your reasoning or sketch it first.');
    }

    return const KnowledgeState(
      skill: 'Missing prerequisite: causal drivers',
      gapLabel: 'GAP',
      message:
          'The gap looks like choosing a tool before naming the defect driver, evidence, and likely cause chain.',
      pathTitle: 'Personalized path generated',
      pathMeta: '12-15 min   •   3 skills',
      pathDescription:
          'Start with prerequisites, then practice root-cause questions.',
    );
  }
}
