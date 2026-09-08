enum ScoringEventType { run, wicket, wide, noBall }

class ScoringEvent {
  const ScoringEvent({
    this.id,
    required this.type,
    required this.runs,
    required this.legalBall,
    required this.overNumber,
    required this.ballNumber,
    this.wideRuns = 0,
    this.noBallRuns = 0,
    this.timestamp,
  });

  final int? id;
  final ScoringEventType type;
  final int runs;
  final bool legalBall;
  final int overNumber;
  final int ballNumber;
  final int wideRuns;
  final int noBallRuns;
  final DateTime? timestamp;

  Map<String, Object?> toMap({required int matchId}) {
    return {
      'id': id,
      'match_id': matchId,
      'over_number': overNumber,
      'ball_number': ballNumber,
      'event_type': type.name,
      'runs': runs,
      'legal_ball': legalBall ? 1 : 0,
      'wide_runs': wideRuns,
      'no_ball_runs': noBallRuns,
      'wicket': type == ScoringEventType.wicket ? 1 : 0,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory ScoringEvent.fromMap(Map<String, Object?> map) {
    return ScoringEvent(
      id: map['id'] as int?,
      type: ScoringEventType.values.byName(map['event_type'] as String),
      runs: map['runs'] as int,
      legalBall: map['legal_ball'] == 1,
      overNumber: map['over_number'] as int,
      ballNumber: map['ball_number'] as int,
      wideRuns: map['wide_runs'] as int,
      noBallRuns: map['no_ball_runs'] as int,
      timestamp: map['timestamp'] == null
          ? null
          : DateTime.parse(map['timestamp'] as String),
    );
  }
}