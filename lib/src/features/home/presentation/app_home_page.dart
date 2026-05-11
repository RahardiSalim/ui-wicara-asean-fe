import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/wicara_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/language_chip.dart';

enum _HomeTab { home, queue, progress, profile }

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  _HomeTab _selectedTab = _HomeTab.home;

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
                child: Stack(
                  children: [
                    Positioned.fill(child: _tabView(constraints)),
                    Positioned(
                      left: 28,
                      right: 28,
                      bottom: 18,
                      child: _ShortcutBar(
                        selectedTab: _selectedTab,
                        onSelected: (tab) => setState(() => _selectedTab = tab),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabView(BoxConstraints constraints) {
    return switch (_selectedTab) {
      _HomeTab.home => _HomeDashboard(
        constraints: constraints,
        onOpenQueue: () => setState(() => _selectedTab = _HomeTab.queue),
      ),
      _HomeTab.queue => _LearningQueue(
        constraints: constraints,
        onBack: () => setState(() => _selectedTab = _HomeTab.home),
      ),
      _HomeTab.progress => const _EmptyTab(
        title: 'Progress',
        subtitle: 'Progress mockup page',
        icon: Icons.bar_chart_rounded,
      ),
      _HomeTab.profile => const _EmptyTab(
        title: 'Profile',
        subtitle: 'Profile mockup page',
        icon: Icons.person_outline_rounded,
      ),
    };
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.constraints, required this.onOpenQueue});

  final BoxConstraints constraints;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 118),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 136),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_MiniWordmark(), LanguageChip()],
            ),
            const SizedBox(height: 38),
            Text(
              'Welcome back, Aisha 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 23, height: 1.12),
            ),
            const SizedBox(height: 7),
            Text(
              'Your path adapts. You grow.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WicaraColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 35),
            _TodayQueueCard(onViewAll: onOpenQueue),
            const SizedBox(height: 25),
            const _StreakCard(),
            const SizedBox(height: 24),
            const _DailyEvaluationCard(),
            const SizedBox(height: 24),
            const _MasteryOverviewCard(),
          ],
        ),
      ),
    );
  }
}

class _LearningQueue extends StatelessWidget {
  const _LearningQueue({required this.constraints, required this.onBack});

  final BoxConstraints constraints;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 118),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 132),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QueueHeader(onBack: onBack),
            const SizedBox(height: 50),
            Text(
              'Your learning queue',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.12),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Flexible(
                  child: Text(
                    "Personalized by WICARA's path engine",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.info_outline_rounded,
                  color: WicaraColors.softMuted,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _QueueTabs(),
            const SizedBox(height: 28),
            const _PriorityCallout(),
            const SizedBox(height: 22),
            const _QueueLessonCard(
              index: '1',
              badge: 'Next up',
              title: 'Repair exponents',
              subject: 'Algebra',
              reason:
                  'Why now? Strengthens your foundation for\npolynomial expressions.',
              meta: '18 min   •   Medium',
              action: 'Continue',
              iconText: 'xⁿ',
              isPrimary: true,
            ),
            const SizedBox(height: 20),
            const _QueueLessonCard(
              index: '2',
              title: 'Continue derivatives',
              subject: 'Calculus',
              reason:
                  "Why now? You're 60% there—finishing this\nunlocks optimization.",
              meta: '24 min   •   Hard',
              action: 'Continue',
              iconText: 'd\ndx',
            ),
            const SizedBox(height: 20),
            const _QueueLessonCard(
              index: '3',
              title: 'Review due',
              subject: 'Functions',
              reason: 'Why now? Spaced review boosts long-term\nretention.',
              meta: '12 min   •   Easy',
              action: 'Review',
              iconData: Icons.event_note_outlined,
            ),
            const SizedBox(height: 18),
            Text(
              'Up next',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 11),
            const _QueueLessonCard(
              index: '',
              title: 'Intro to logarithms',
              subject: 'Logs',
              reason: '',
              meta: '20 min   •   Medium',
              action: '',
              iconText: 'logₐ',
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.chevron_left_rounded),
          iconSize: 33,
          color: WicaraColors.ink,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 38, height: 38),
        ),
        const LanguageChip(),
      ],
    );
  }
}

class _TodayQueueCard extends StatelessWidget {
  const _TodayQueueCard({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's learning queue",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View all',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: WicaraColors.periwinkle,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SoftBadge('Next up'),
                    const SizedBox(height: 11),
                    Text(
                      'Repair exponents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Algebra',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WicaraColors.muted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Estimated 18 min   •   Medium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WicaraColors.softMuted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const _LessonGlyph(text: 'xⁿ', size: 73),
            ],
          ),
          const SizedBox(height: 24),
          GradientButton(label: 'Continue session', onPressed: () {}),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(19, 18, 19, 18),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WicaraColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '7 days',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 146, child: _WeekDots()),
        ],
      ),
    );
  }
}

class _DailyEvaluationCard extends StatelessWidget {
  const _DailyEvaluationCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daily evaluation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            "How confident do you feel about today's topics?",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WicaraColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              for (var score = 1; score <= 5; score++) ...[
                Expanded(
                  child: Container(
                    height: 39,
                    decoration: BoxDecoration(
                      gradient: score == 3
                          ? WicaraColors.primaryGradient
                          : null,
                      color: score == 3 ? null : const Color(0xFFF4F5FA),
                      borderRadius: BorderRadius.circular(10),
                      border: score == 3
                          ? null
                          : Border.all(color: WicaraColors.line),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$score',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: score == 3 ? Colors.white : WicaraColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                if (score < 5) const SizedBox(width: 11),
              ],
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            height: 16,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Not confident',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Very confident',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryOverviewCard extends StatelessWidget {
  const _MasteryOverviewCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 21),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mastery overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'View details',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WicaraColors.periwinkle,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _MasteryRow(
            label: 'Algebra',
            value: 0.72,
            percent: '72%',
            status: 'Good',
          ),
          const SizedBox(height: 17),
          const _MasteryRow(
            label: 'Calculus',
            value: 0.58,
            percent: '58%',
            status: 'Growing',
          ),
          const SizedBox(height: 17),
          const _MasteryRow(
            label: 'Functions',
            value: 0.84,
            percent: '84%',
            status: 'Strong',
          ),
        ],
      ),
    );
  }
}

class _QueueTabs extends StatelessWidget {
  const _QueueTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: WicaraColors.shadowBlue.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Next steps',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WicaraColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Recommended',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: WicaraColors.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityCallout extends StatelessWidget {
  const _PriorityCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 18, 19, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: WicaraColors.periwinkle.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: WicaraColors.periwinkle,
            size: 21,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "We're prioritizing topics that will unlock the\nmost progress for you right now.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.text,
                fontWeight: FontWeight.w800,
                height: 1.32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueLessonCard extends StatelessWidget {
  const _QueueLessonCard({
    required this.index,
    required this.title,
    required this.subject,
    required this.reason,
    required this.meta,
    required this.action,
    this.badge,
    this.iconText,
    this.iconData,
    this.isPrimary = false,
    this.compact = false,
  });

  final String index;
  final String title;
  final String subject;
  final String reason;
  final String meta;
  final String action;
  final String? badge;
  final String? iconText;
  final IconData? iconData;
  final bool isPrimary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.fromLTRB(
        20,
        compact ? 15 : 18,
        20,
        compact ? 15 : 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (index.isNotEmpty) ...[
                      _NumberBadge(index),
                      const SizedBox(width: 10),
                    ],
                    if (badge != null) _SoftBadge(badge!),
                  ],
                ),
                if (index.isNotEmpty || badge != null)
                  const SizedBox(height: 11),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 14 : 18,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subject,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WicaraColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    reason,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WicaraColors.muted,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WicaraColors.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (action.isNotEmpty)
                      _SmallActionButton(label: action, filled: isPrimary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          _LessonGlyph(text: iconText, icon: iconData, size: compact ? 54 : 64),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 112,
      decoration: BoxDecoration(
        gradient: filled ? WicaraColors.primaryGradient : null,
        color: filled ? null : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: filled
            ? null
            : Border.all(
                color: WicaraColors.periwinkle.withValues(alpha: 0.45),
                width: 1.4,
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: filled ? Colors.white : WicaraColors.periwinkle,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ShortcutBar extends StatelessWidget {
  const _ShortcutBar({required this.selectedTab, required this.onSelected});

  final _HomeTab selectedTab;
  final ValueChanged<_HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: WicaraColors.line, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: WicaraColors.shadowBlue.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _ShortcutItem(
            tab: _HomeTab.home,
            selectedTab: selectedTab,
            icon: Icons.home_rounded,
            label: 'Home',
            onSelected: onSelected,
          ),
          _ShortcutItem(
            tab: _HomeTab.queue,
            selectedTab: selectedTab,
            icon: Icons.format_list_bulleted_rounded,
            label: 'Queue',
            onSelected: onSelected,
          ),
          _ShortcutItem(
            tab: _HomeTab.progress,
            selectedTab: selectedTab,
            icon: Icons.bar_chart_rounded,
            label: 'Progress',
            onSelected: onSelected,
          ),
          _ShortcutItem(
            tab: _HomeTab.profile,
            selectedTab: selectedTab,
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.tab,
    required this.selectedTab,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final _HomeTab tab;
  final _HomeTab selectedTab;
  final IconData icon;
  final String label;
  final ValueChanged<_HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    final color = isSelected ? WicaraColors.periwinkle : WicaraColors.muted;

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(tab),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 118),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerRight, child: LanguageChip()),
          const Spacer(),
          Icon(icon, color: WicaraColors.periwinkle, size: 52),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WicaraColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: WicaraColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: WicaraColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 17,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniWordmark extends StatelessWidget {
  const _MiniWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomPaint(size: Size(51, 31), painter: _MiniMarkPainter()),
        const SizedBox(width: 13),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: 'WICARA'
              .split('')
              .map(
                (letter) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.7),
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: WicaraColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MiniMarkPainter extends CustomPainter {
  const _MiniMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.height * 0.45
        ..color = WicaraColors.periwinkle.withValues(alpha: 0.32),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.height * 0.45
        ..color = WicaraColors.lavender.withValues(alpha: 0.58),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.height * 0.45
        ..color = WicaraColors.periwinkle.withValues(alpha: 0.23),
    ];

    for (var i = 0; i < 3; i++) {
      final offset = i * size.width * 0.22;
      final path = Path()
        ..moveTo(size.width * 0.08 + offset, size.height * 0.24)
        ..cubicTo(
          size.width * 0.15 + offset,
          size.height * 0.65,
          size.width * 0.25 + offset,
          size.height * 0.75,
          size.width * 0.34 + offset,
          size.height * 0.72,
        )
        ..cubicTo(
          size.width * 0.43 + offset,
          size.height * 0.69,
          size.width * 0.45 + offset,
          size.height * 0.37,
          size.width * 0.52 + offset,
          size.height * 0.24,
        );
      canvas.drawPath(path, paints[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LessonGlyph extends StatelessWidget {
  const _LessonGlyph({this.text, this.icon, this.size = 64});

  final String? text;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FF),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: WicaraColors.periwinkle, size: size * 0.43)
          : Text(
              text ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: WicaraColors.periwinkle,
                fontSize: size * 0.32,
                fontWeight: FontWeight.w900,
                height: 0.9,
              ),
            ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: WicaraColors.periwinkle,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: WicaraColors.periwinkle,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots();

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Text(
                labels[i],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WicaraColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (i < labels.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: i < 6 ? WicaraColors.periwinkle : Colors.white,
                  shape: BoxShape.circle,
                  border: i < 6
                      ? null
                      : Border.all(color: WicaraColors.softMuted, width: 1.4),
                ),
              ),
              if (i < labels.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({
    required this.label,
    required this.value,
    required this.percent,
    required this.status,
  });

  final String label;
  final double value;
  final String percent;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: WicaraColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              color: WicaraColors.periwinkle,
              backgroundColor: WicaraColors.line,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 92,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '$percent   •   $status',
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WicaraColors.muted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
