enum MatchStatus { notStarted, inProgress, inningsBreak, completed, abandoned }

enum MatchMode { newMatch, manualFirstInnings }

class CricketMatch {
  const CricketMatch({
    this.id,
    required this.teamAName,
    required this.teamBName,
    required this.overs,
    required this.wideEnabled,
    required this.noBallEnabled,
    required this.playerTrackingEnabled,
    required this.mode,
    this.target,
    this.battingFirstTeam,
    this.currentInnings = 1,
    this.firstInningsRuns,
    this.winner,
    this.resultText,
    this.status = MatchStatus.notStarted,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String teamAName;
  final String teamBName;
  final int overs;
  final bool wideEnabled;
  final bool noBallEnabled;
  final bool playerTrackingEnabled;
  final MatchMode mode;
  final int? target;
  final String? battingFirstTeam;
  final int currentInnings;
  final int? firstInningsRuns;
  final String? winner;
  final String? resultText;
  final MatchStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'team_a_name': teamAName,
      'team_b_name': teamBName,
      'overs': overs,
      'wide_enabled': wideEnabled ? 1 : 0,
      'no_ball_enabled': noBallEnabled ? 1 : 0,
      'player_tracking_enabled': playerTrackingEnabled ? 1 : 0,
      'match_mode': mode.name,
      'target': target,
      'batting_first_team': battingFirstTeam,
      'current_innings': currentInnings,
      'first_innings_runs': firstInningsRuns,
      'winner': winner,
      'result_text': resultText,
      'status': status.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CricketMatch.fromMap(Map<String, Object?> map) {
    return CricketMatch(
      id: map['id'] as int?,
      teamAName: map['team_a_name'] as String,
      teamBName: map['team_b_name'] as String,
      overs: map['overs'] as int,
      wideEnabled: map['wide_enabled'] == 1,
      noBallEnabled: map['no_ball_enabled'] == 1,
      playerTrackingEnabled: map['player_tracking_enabled'] == 1,
      mode: MatchMode.values.byName(map['match_mode'] as String),
      target: map['target'] as int?,
      battingFirstTeam: map['batting_first_team'] as String?,
      currentInnings: map['current_innings'] as int? ?? 1,
      firstInningsRuns: map['first_innings_runs'] as int?,
      winner: map['winner'] as String?,
      resultText: map['result_text'] as String?,
      status: MatchStatus.values.byName(map['status'] as String),
      createdAt: _dateFromMap(map['created_at']),
      updatedAt: _dateFromMap(map['updated_at']),
    );
  }

  static DateTime? _dateFromMap(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }

  CricketMatch copyWith({
    int? id,
    MatchMode? mode,
    int? target,
    String? battingFirstTeam,
    MatchStatus? status,
    DateTime? updatedAt,
    int? currentInnings,
    int? firstInningsRuns,
    String? winner,
    String? resultText,
  }) {
    return CricketMatch(
      id: id ?? this.id,
      teamAName: teamAName,
      teamBName: teamBName,
      overs: overs,
      wideEnabled: wideEnabled,
      noBallEnabled: noBallEnabled,
      playerTrackingEnabled: playerTrackingEnabled,
      mode: mode ?? this.mode,
      target: target ?? this.target,
      battingFirstTeam: battingFirstTeam ?? this.battingFirstTeam,
      currentInnings: currentInnings ?? this.currentInnings,
      firstInningsRuns: firstInningsRuns ?? this.firstInningsRuns,
      winner: winner ?? this.winner,
      resultText: resultText ?? this.resultText,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}