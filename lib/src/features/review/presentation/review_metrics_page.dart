import 'package:flutter/material.dart';

import '../../../core/theme/wicara_colors.dart';
import '../application/review_controller.dart';
import '../domain/review_models.dart';
import 'review_widgets.dart';

/// "How often is human correction needed" dashboard.
class ReviewMetricsPage extends StatefulWidget {
  const ReviewMetricsPage({required this.repository, super.key});

  final ReviewRepository repository;

  @override
  State<ReviewMetricsPage> createState() => _ReviewMetricsPageState();
}

class _ReviewMetricsPageState extends State<ReviewMetricsPage> {
  late final ReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReviewController(repository: widget.repository);
    _controller.loadMetrics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _pct(double value) => '${(value * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WicaraColors.pageBackground,
      appBar: AppBar(
        title: const Text('Correction metrics'),
        backgroundColor: Colors.white,
        foregroundColor: WicaraColors.ink,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoadingMetrics && _controller.metrics == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final metrics = _controller.metrics;
          if (metrics == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _controller.metricsError ?? 'No metrics yet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: WicaraColors.muted),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.loadMetrics,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _headline(metrics),
                const SizedBox(height: 12),
                _smallStats(metrics),
                const SizedBox(height: 16),
                _byTypeSection(metrics),
                const SizedBox(height: 16),
                _triggerSection(metrics),
                const SizedBox(height: 16),
                _timeSeriesSection(metrics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headline(ReviewMetrics m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WicaraColors.primaryDeep, WicaraColors.secondaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Human correction rate',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _pct(m.correctionRate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${m.correctedTotal} corrected of ${m.reviewedTotal} reviewed',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _smallStats(ReviewMetrics m) {
    return Row(
      children: [
        _statCard('Approved', _pct(m.approvalRate), WicaraColors.accentMint),
        const SizedBox(width: 10),
        _statCard('Rejected', _pct(m.rejectionRate), WicaraColors.accentCoral),
        const SizedBox(width: 10),
        _statCard(
          'Backlog',
          '${m.backlogOpen}',
          WicaraColors.accentAmber,
          subtitle: m.backlogOldestAgeDays != null
              ? 'oldest ${m.backlogOldestAgeDays!.toStringAsFixed(1)}d'
              : 'none open',
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: WicaraColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: WicaraColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(color: WicaraColors.softMuted, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  Widget _byTypeSection(ReviewMetrics m) {
    return _card('Correction rate by type', [
      if (m.byType.isEmpty)
        const Text('No reviewed items yet.',
            style: TextStyle(color: WicaraColors.muted))
      else
        ...m.byType.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reviewLabel(t.artifactType),
                        style: const TextStyle(
                          color: WicaraColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_pct(t.correctionRate)} · ${t.reviewed} reviewed',
                      style: const TextStyle(color: WicaraColors.muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: t.correctionRate.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: WicaraColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation(WicaraColors.primaryDeep),
                  ),
                ),
              ],
            ),
          );
        }),
    ]);
  }

  Widget _triggerSection(ReviewMetrics m) {
    return _card('Trigger precision', [
      const Text(
        'Of items a trigger flagged, how many turned out to need a fix '
        '(corrected or rejected). Higher = the trigger is worth a teacher\'s time.',
        style: TextStyle(color: WicaraColors.muted, fontSize: 12),
      ),
      const SizedBox(height: 8),
      if (m.triggerPrecision.isEmpty)
        const Text('No resolved items yet.',
            style: TextStyle(color: WicaraColors.muted))
      else
        ...m.triggerPrecision.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                TriggerBadge(trigger: t.trigger),
                const Spacer(),
                Text(
                  '${_pct(t.precision)}  (${t.caughtProblem}/${t.totalResolved})',
                  style: const TextStyle(
                    color: WicaraColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }),
    ]);
  }

  Widget _timeSeriesSection(ReviewMetrics m) {
    final maxReviewed = m.timeSeries.fold<int>(
      1,
      (acc, p) => p.reviewed > acc ? p.reviewed : acc,
    );
    return _card('Last 14 days', [
      if (m.timeSeries.isEmpty)
        const Text('No activity in the last 14 days.',
            style: TextStyle(color: WicaraColors.muted))
      else
        ...m.timeSeries.map((p) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  child: Text(
                    p.date,
                    style: const TextStyle(color: WicaraColors.muted, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(height: 14, color: WicaraColors.primarySoft),
                        FractionallySizedBox(
                          widthFactor: (p.reviewed / maxReviewed).clamp(0, 1),
                          child: Container(height: 14, color: WicaraColors.primaryLight),
                        ),
                        FractionallySizedBox(
                          widthFactor: (p.corrected / maxReviewed).clamp(0, 1),
                          child: Container(height: 14, color: WicaraColors.primaryDeep),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${p.corrected}/${p.reviewed}',
                  style: const TextStyle(color: WicaraColors.text, fontSize: 11),
                ),
              ],
            ),
          );
        }),
      const SizedBox(height: 6),
      const Text(
        'Dark = corrected · light = reviewed',
        style: TextStyle(color: WicaraColors.softMuted, fontSize: 11),
      ),
    ]);
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WicaraColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: WicaraColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
