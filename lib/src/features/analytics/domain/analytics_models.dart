// Domain models for long-term learning analytics. Mirror the backend
// app/modules/analytics schemas.

double _toDouble(Object? v) => v == null ? 0 : (v as num).toDouble();
int _toInt(Object? v) => v == null ? 0 : (v as num).toInt();
String _toStr(Object? v) => v == null ? '' : v.toString();

class SubjectMastery {
  const SubjectMastery({
    required this.subjectCode,
    required this.subjectName,
    required this.conceptsTracked,
    required this.mastered,
    required this.gaps,
    required this.avgMastery,
  });

  final String subjectCode;
  final String subjectName;
  final int conceptsTracked;
  final int mastered;
  final int gaps;
  final double avgMastery;

  factory SubjectMastery.fromJson(Map<String, dynamic> j) => SubjectMastery(
    subjectCode: _toStr(j['subject_code']),
    subjectName: _toStr(j['subject_name']),
    conceptsTracked: _toInt(j['concepts_tracked']),
    mastered: _toInt(j['mastered']),
    gaps: _toInt(j['gaps']),
    avgMastery: _toDouble(j['avg_mastery']),
  );
}

class AnalyticsOverview {
  const AnalyticsOverview({
    required this.subjects,
    required this.subjectsStudied,
    required this.conceptsTracked,
    required this.overallAvgMastery,
    required this.totalAttempts,
    required this.activeDays,
  });

  final List<SubjectMastery> subjects;
  final int subjectsStudied;
  final int conceptsTracked;
  final double overallAvgMastery;
  final int totalAttempts;
  final int activeDays;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> j) => AnalyticsOverview(
    subjects: (j['subjects'] as List? ?? const [])
        .map((e) => SubjectMastery.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false),
    subjectsStudied: _toInt(j['subjects_studied']),
    conceptsTracked: _toInt(j['concepts_tracked']),
    overallAvgMastery: _toDouble(j['overall_avg_mastery']),
    totalAttempts: _toInt(j['total_attempts']),
    activeDays: _toInt(j['active_days']),
  );
}

class TrendPoint {
  const TrendPoint({
    required this.period,
    required this.score,
    required this.attempts,
    required this.fixedGaps,
    required this.remainingGaps,
  });

  final String period;
  final int score;
  final int attempts;
  final int fixedGaps;
  final int remainingGaps;

  factory TrendPoint.fromJson(Map<String, dynamic> j) => TrendPoint(
    period: _toStr(j['period']),
    score: _toInt(j['score']),
    attempts: _toInt(j['attempts']),
    fixedGaps: _toInt(j['fixed_gaps']),
    remainingGaps: _toInt(j['remaining_gaps']),
  );
}

class AnalyticsTrends {
  const AnalyticsTrends({required this.period, required this.points});

  final String period;
  final List<TrendPoint> points;

  factory AnalyticsTrends.fromJson(Map<String, dynamic> j) => AnalyticsTrends(
    period: _toStr(j['period']),
    points: (j['points'] as List? ?? const [])
        .map((e) => TrendPoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false),
  );
}

class AnalyticsVelocity {
  const AnalyticsVelocity({
    required this.totalAttempts,
    required this.activeDays,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.conceptsMastered,
    required this.conceptsTracked,
    required this.avgAttemptsPerActiveDay,
    required this.firstActive,
    required this.lastActive,
  });

  final int totalAttempts;
  final int activeDays;
  final int currentStreakDays;
  final int longestStreakDays;
  final int conceptsMastered;
  final int conceptsTracked;
  final double avgAttemptsPerActiveDay;
  final String? firstActive;
  final String? lastActive;

  factory AnalyticsVelocity.fromJson(Map<String, dynamic> j) => AnalyticsVelocity(
    totalAttempts: _toInt(j['total_attempts']),
    activeDays: _toInt(j['active_days']),
    currentStreakDays: _toInt(j['current_streak_days']),
    longestStreakDays: _toInt(j['longest_streak_days']),
    conceptsMastered: _toInt(j['concepts_mastered']),
    conceptsTracked: _toInt(j['concepts_tracked']),
    avgAttemptsPerActiveDay: _toDouble(j['avg_attempts_per_active_day']),
    firstActive: j['first_active']?.toString(),
    lastActive: j['last_active']?.toString(),
  );
}

class AtRiskItem {
  const AtRiskItem({
    required this.conceptId,
    required this.title,
    required this.subjectCode,
    required this.subjectName,
    required this.mastery,
    required this.confidence,
    required this.overdueDays,
    required this.retentionEstimate,
    required this.riskScore,
  });

  final String conceptId;
  final String title;
  final String subjectCode;
  final String subjectName;
  final double mastery;
  final double confidence;
  final double? overdueDays;
  final double? retentionEstimate;
  final double riskScore;

  factory AtRiskItem.fromJson(Map<String, dynamic> j) => AtRiskItem(
    conceptId: _toStr(j['concept_id']),
    title: _toStr(j['title']),
    subjectCode: _toStr(j['subject_code']),
    subjectName: _toStr(j['subject_name']),
    mastery: _toDouble(j['mastery']),
    confidence: _toDouble(j['confidence']),
    overdueDays: j['overdue_days'] == null ? null : _toDouble(j['overdue_days']),
    retentionEstimate:
        j['retention_estimate'] == null ? null : _toDouble(j['retention_estimate']),
    riskScore: _toDouble(j['risk_score']),
  );
}

class AnalyticsAtRisk {
  const AnalyticsAtRisk({required this.items, required this.totalAtRisk});

  final List<AtRiskItem> items;
  final int totalAtRisk;

  factory AnalyticsAtRisk.fromJson(Map<String, dynamic> j) => AnalyticsAtRisk(
    items: (j['items'] as List? ?? const [])
        .map((e) => AtRiskItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false),
    totalAtRisk: _toInt(j['total_at_risk']),
  );
}

abstract class AnalyticsRepository {
  Future<AnalyticsOverview> fetchOverview();
  Future<AnalyticsTrends> fetchTrends({String period = 'month'});
  Future<AnalyticsVelocity> fetchVelocity();
  Future<AnalyticsAtRisk> fetchAtRisk({int limit = 20});
}
