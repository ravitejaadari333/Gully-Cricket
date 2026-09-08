import '../models/scoring_event.dart';

class ScoreSummary {
  const ScoreSummary({
    required this.runs,
    required this.wickets,
    required this.legalBalls,
    required this.wideRuns,
    required this.noBallRuns,
  });

  final int runs;
  final int wickets;
  final int legalBalls;
  final int wideRuns;
  final int noBallRuns;

  int get completedOvers => legalBalls ~/ 6;
  int get ballsInCurrentOver => legalBalls % 6;

  String get oversDisplay => '$completedOvers.$ballsInCurrentOver';
}

class ScoringEngine {
  ScoringEngine({this.maxOvers, Iterable<ScoringEvent>? initialEvents}) {
    if (initialEvents != null) _events.addAll(initialEvents);
  }

  final int? maxOvers;
  final List<ScoringEvent> _events = [];

  List<ScoringEvent> get events => List.unmodifiable(_events);
  ScoreSummary get score => _calculateScore(_events);
  bool get canUndo => _events.isNotEmpty;

  void addRun(int runs) {
    if (runs < 0 || runs > 6) {
      throw ArgumentError.value(runs, 'runs', 'Runs must be between 0 and 6.');
    }
    _addEvent(ScoringEventType.run, runs: runs, legalBall: true);
  }

  void addWicket() {
    _addEvent(ScoringEventType.wicket, runs: 0, legalBall: true);
  }

  void addWide({int runs = 1}) {
    if (runs < 0) {
      throw ArgumentError.value(runs, 'runs', 'Wide runs cannot be negative.');
    }
    _addEvent(
      ScoringEventType.wide,
      runs: runs,
      legalBall: false,
      wideRuns: runs,
    );
  }

  void addNoBall({int runs = 1}) {
    if (runs < 0) {
      throw ArgumentError.value(
        runs,
        'runs',
        'No-ball runs cannot be negative.',
      );
    }
    _addEvent(
      ScoringEventType.noBall,
      runs: runs,
      legalBall: false,
      noBallRuns: runs == 0 ? 0 : 1,
    );
  }

  void undo() {
    if (_events.isNotEmpty) _events.removeLast();
  }

  void replaceEvents(Iterable<ScoringEvent> events) {
    _events
      ..clear()
      ..addAll(events);
  }

  bool isInningsComplete({int? wickets, int? target}) {
    final currentScore = score;
    return (maxOvers != null && currentScore.legalBalls >= maxOvers! * 6) ||
        (wickets != null && currentScore.wickets >= wickets) ||
        (target != null && currentScore.runs >= target);
  }

  void _addEvent(
    ScoringEventType type, {
    required int runs,
    required bool legalBall,
    int wideRuns = 0,
    int noBallRuns = 0,
  }) {
    final currentScore = score;
    if (maxOvers != null && currentScore.legalBalls >= maxOvers! * 6) {
      throw StateError('The configured overs are complete.');
    }

    _events.add(
      ScoringEvent(
        type: type,
        runs: runs,
        legalBall: legalBall,
        overNumber: currentScore.completedOvers + 1,
        ballNumber: currentScore.ballsInCurrentOver + 1,
        wideRuns: wideRuns,
        noBallRuns: noBallRuns,
        timestamp: DateTime.now(),
      ),
    );
  }

  ScoreSummary _calculateScore(List<ScoringEvent> events) {
    var runs = 0;
    var wickets = 0;
    var legalBalls = 0;
    var wideRuns = 0;
    var noBallRuns = 0;

    for (final event in events) {
      runs += event.runs;
      if (event.type == ScoringEventType.wicket) wickets++;
      if (event.legalBall) legalBalls++;
      wideRuns += event.wideRuns;
      noBallRuns += event.noBallRuns;
    }
    return ScoreSummary(
      runs: runs,
      wickets: wickets,
      legalBalls: legalBalls,
      wideRuns: wideRuns,
      noBallRuns: noBallRuns,
    );
  }
}
