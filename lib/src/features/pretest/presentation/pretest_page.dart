import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/language_chip.dart';
import '../domain/pretest_models.dart';
import '../domain/pretest_repository.dart';
import 'widgets/assessment_option_tile.dart';
import 'widgets/confidence_picker.dart';
import 'widgets/fishbone_canvas.dart';
import 'widgets/knowledge_state_card.dart';

enum _PretestStage { question, reasoning, result }

class PretestPage extends StatefulWidget {
  const PretestPage({required this.pretestRepository, super.key});

  final PretestRepository pretestRepository;

  @override
  State<PretestPage> createState() => _PretestPageState();
}

class _PretestPageState extends State<PretestPage> {
  final _reasoningController = TextEditingController(
    text:
        'I chose B because defects are the outcome we need to understand before changing the process.',
  );

  _PretestStage _stage = _PretestStage.question;
  String _selectedOptionId = 'B';
  int _confidence = 6;
  bool _isCanvasExpanded = true;
  bool _isSubmitting = false;
  KnowledgeState? _knowledgeState;

  static const _question = PretestQuestion(
    stepLabel: '2 / 12',
    topic: 'Knowledge Space Theory',
    prompt:
        'A company introduces a new\nprocess that reduces cycle\ntime but increases defect rate.\nWhat should they evaluate first?',
    helper: 'Select the best next step to guide\nimprovement.',
    options: [
      PretestOption(
        id: 'A',
        label: 'A',
        text: 'Increase automation\nto reduce variability',
      ),
      PretestOption(
        id: 'B',
        label: 'B',
        text: 'Run a root cause analysis\non defect drivers',
      ),
      PretestOption(id: 'C', label: 'C', text: 'Set tighter production quotas'),
      PretestOption(id: 'D', label: 'D', text: 'Reduce inspection frequency'),
    ],
  );

  @override
  void dispose() {
    _reasoningController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.pretestRepository.submitAnswer(_answer);
      if (!mounted) {
        return;
      }
      setState(() => _stage = _PretestStage.reasoning);
    } on PretestException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitReasoning() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await widget.pretestRepository.submitReasoning(
        PretestReasoning(
          answer: _answer,
          explanation: _reasoningController.text,
          usedCanvas: _isCanvasExpanded,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _knowledgeState = result;
        _stage = _PretestStage.result;
      });
    } on PretestException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  PretestAnswer get _answer {
    return PretestAnswer(
      questionId: 'root-cause-analysis-001',
      optionId: _selectedOptionId,
      confidence: _confidence,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _goBack() {
    if (_stage == _PretestStage.reasoning) {
      setState(() => _stage = _PretestStage.question);
      return;
    }
    if (_stage == _PretestStage.result) {
      setState(() => _stage = _PretestStage.reasoning);
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 430.0);

            return Center(
              child: SizedBox(
                width: pageWidth,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_stage),
                    child: _stageView(constraints),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stageView(BoxConstraints constraints) {
    return switch (_stage) {
      _PretestStage.question => _QuestionStage(
        constraints: constraints,
        question: _question,
        selectedOptionId: _selectedOptionId,
        confidence: _confidence,
        isSubmitting: _isSubmitting,
        onClose: _goBack,
        onSelected: (id) => setState(() => _selectedOptionId = id),
        onConfidenceChanged: (value) => setState(() => _confidence = value),
        onSubmit: _submitAnswer,
      ),
      _PretestStage.reasoning => _ReasoningStage(
        constraints: constraints,
        controller: _reasoningController,
        isCanvasExpanded: _isCanvasExpanded,
        isSubmitting: _isSubmitting,
        onBack: _goBack,
        onToggleCanvas: () {
          setState(() => _isCanvasExpanded = !_isCanvasExpanded);
        },
        onSubmit: _submitReasoning,
      ),
      _PretestStage.result => _ResultStage(
        constraints: constraints,
        result: _knowledgeState,
        onContinue: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      ),
    };
  }
}

class _QuestionStage extends StatelessWidget {
  const _QuestionStage({
    required this.constraints,
    required this.question,
    required this.selectedOptionId,
    required this.confidence,
    required this.isSubmitting,
    required this.onClose,
    required this.onSelected,
    required this.onConfidenceChanged,
    required this.onSubmit,
  });

  final BoxConstraints constraints;
  final PretestQuestion question;
  final String selectedOptionId;
  final int confidence;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<String> onSelected;
  final ValueChanged<int> onConfidenceChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AssessmentHeader(
              leading: Icons.close_rounded,
              onLeadingPressed: onClose,
            ),
            const SizedBox(height: 54),
            Text(
              question.stepLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: WicaraColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _SlimProgress(value: 2 / 12),
            const SizedBox(height: 31),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 21),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: WicaraColors.line, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: WicaraColors.shadowBlue.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FF),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: WicaraColors.line),
                      ),
                      child: Text(
                        question.topic,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WicaraColors.muted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    question.prompt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    question.helper,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 26),
                  for (
                    var index = 0;
                    index < question.options.length;
                    index++
                  ) ...[
                    AssessmentOptionTile(
                      option: question.options[index],
                      isSelected:
                          question.options[index].id == selectedOptionId,
                      onTap: () => onSelected(question.options[index].id),
                    ),
                    if (index < question.options.length - 1)
                      const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 19),
                  ConfidencePicker(
                    value: confidence,
                    onChanged: onConfidenceChanged,
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Submit answer',
                    onPressed: onSubmit,
                    isLoading: isSubmitting,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _AssessmentFooter(),
          ],
        ),
      ),
    );
  }
}

class _ReasoningStage extends StatelessWidget {
  const _ReasoningStage({
    required this.constraints,
    required this.controller,
    required this.isCanvasExpanded,
    required this.isSubmitting,
    required this.onBack,
    required this.onToggleCanvas,
    required this.onSubmit,
  });

  final BoxConstraints constraints;
  final TextEditingController controller;
  final bool isCanvasExpanded;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onToggleCanvas;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AssessmentHeader(
              leading: Icons.chevron_left_rounded,
              onLeadingPressed: onBack,
            ),
            const SizedBox(height: 48),
            Text(
              'Help us understand your thinking',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 22, height: 1.14),
            ),
            const SizedBox(height: 8),
            Text(
              'Use chat or canvas — same evidence pipeline.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WicaraColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 27),
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                text:
                    'I chose B because defects\nare the outcome we need to\nunderstand before changing\nthe process.',
                isUser: true,
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                text: 'Great — show your reasoning\nor sketch your analysis.',
                isUser: false,
              ),
            ),
            const SizedBox(height: 31),
            _ReasoningTabs(
              isCanvasExpanded: isCanvasExpanded,
              onToggleCanvas: onToggleCanvas,
            ),
            const SizedBox(height: 16),
            FishboneCanvas(
              isExpanded: isCanvasExpanded,
              onToggleExpanded: onToggleCanvas,
            ),
            const SizedBox(height: 35),
            _ReasoningInput(
              controller: controller,
              isSubmitting: isSubmitting,
              onSubmit: onSubmit,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: WicaraColors.softMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Same evidence pipeline (InputEvent)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStage extends StatelessWidget {
  const _ResultStage({
    required this.constraints,
    required this.result,
    required this.onContinue,
  });

  final BoxConstraints constraints;
  final KnowledgeState? result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final state =
        result ??
        const KnowledgeState(
          skill: 'Root Cause Analysis',
          gapLabel: 'GAP',
          message:
              "You're close - review key frameworks\nand try targeted practice.",
          pathTitle: 'Personalized path generated',
          pathMeta: '12-15 min   •   3 skills',
          pathDescription:
              'Adaptive lessons and practice\nfocused on your gaps.',
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: LanguageChip(),
            ),
            const SizedBox(height: 78),
            Text(
              'Your knowledge state',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 25, height: 1.12),
            ),
            const SizedBox(height: 10),
            Text(
              'Based on your responses and reasoning.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WicaraColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 38),
            KnowledgeStateCard(
              title: state.skill,
              message: state.message,
              badge: state.gapLabel,
              icon: Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: 37),
            Text(
              "What's next",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            KnowledgeStateCard(
              title: state.pathTitle,
              message: '${state.pathMeta}\n${state.pathDescription}',
              badge: '',
              icon: Icons.center_focus_strong_outlined,
              height: 137,
            ),
            const SizedBox(height: 32),
            GradientButton(label: 'Continue to my path', onPressed: onContinue),
            const SizedBox(height: 20),
            Text(
              'You can retake the pretest anytime.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.softMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentHeader extends StatelessWidget {
  const _AssessmentHeader({
    required this.leading,
    required this.onLeadingPressed,
  });

  final IconData leading;
  final VoidCallback onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onLeadingPressed,
          icon: Icon(leading),
          iconSize: leading == Icons.close_rounded ? 28 : 33,
          color: WicaraColors.ink,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        ),
        const LanguageChip(),
      ],
    );
  }
}

class _SlimProgress extends StatelessWidget {
  const _SlimProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        color: WicaraColors.periwinkle,
        backgroundColor: WicaraColors.line,
      ),
    );
  }
}

class _AssessmentFooter extends StatelessWidget {
  const _AssessmentFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.insights_rounded,
          color: WicaraColors.periwinkle,
          size: 19,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Adaptive probing  •  Knowledge Space Theory',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WicaraColors.softMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  WicaraColors.lavender.withValues(alpha: 0.62),
                  WicaraColors.periwinkle.withValues(alpha: 0.28),
                ],
              )
            : null,
        color: isUser ? null : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isUser ? null : Border.all(color: WicaraColors.line),
        boxShadow: [
          BoxShadow(
            color: WicaraColors.shadowBlue.withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isUser ? WicaraColors.text : WicaraColors.muted,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ReasoningTabs extends StatelessWidget {
  const _ReasoningTabs({
    required this.isCanvasExpanded,
    required this.onToggleCanvas,
  });

  final bool isCanvasExpanded;
  final VoidCallback onToggleCanvas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Chat',
                    isActive: !isCanvasExpanded,
                    onTap: onToggleCanvas,
                  ),
                ),
                Expanded(
                  child: _TabButton(
                    label: 'Canvas',
                    isActive: isCanvasExpanded,
                    onTap: onToggleCanvas,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WicaraColors.line),
          ),
          child: const Icon(Icons.more_horiz_rounded, color: WicaraColors.text),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEDEEFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive ? WicaraColors.periwinkle : WicaraColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasoningInput extends StatelessWidget {
  const _ReasoningInput({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              filled: true,
              fillColor: WicaraColors.fieldFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: WicaraColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: WicaraColors.periwinkle),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WicaraColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            gradient: WicaraColors.primaryGradient,
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: WicaraColors.periwinkle.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: IconButton(
            onPressed: isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.arrow_upward_rounded),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
