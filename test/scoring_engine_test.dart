import 'package:flutter_test/flutter_test.dart';

import 'package:cricket_app/models/scoring_event.dart';
import 'package:cricket_app/services/scoring_engine.dart';

void main() {
  test('adds a run and one legal ball', () {
    final engine = ScoringEngine();

    engine.addRun(4);

    expect(engine.score.runs, 4);
    expect(engine.score.legalBalls, 1);
    expect(engine.score.oversDisplay, '0.1');
  });

  test('six legal deliveries display one completed over', () {
    final engine = ScoringEngine();

    for (var index = 0; index < 6; index++) {
      engine.addRun(1);
    }

    expect(engine.score.runs, 6);
    expect(engine.score.legalBalls, 6);
    expect(engine.score.oversDisplay, '1.0');
  });

  test('wicket adds a wicket and consumes one legal ball', () {
    final engine = ScoringEngine();

    engine.addWicket();

    expect(engine.score.wickets, 1);
    expect(engine.score.runs, 0);
    expect(engine.score.legalBalls, 1);
  });

  test('wide adds runs but does not consume a legal ball', () {
    final engine = ScoringEngine();

    engine.addWide();

    expect(engine.score.runs, 1);
    expect(engine.score.wideRuns, 1);
    expect(engine.score.legalBalls, 0);
    expect(engine.events.single.legalBall, isFalse);
  });

  test('multiple wide runs remain one non-legal event', () {
    final engine = ScoringEngine();

    engine.addWide(runs: 3);

    expect(engine.score.runs, 3);
    expect(engine.score.wideRuns, 3);
    expect(engine.score.legalBalls, 0);
  });

  test('wide can be recorded without adding runs', () {
    final engine = ScoringEngine();

    engine.addWide(runs: 0);

    expect(engine.score.runs, 0);
    expect(engine.score.wideRuns, 0);
    expect(engine.score.legalBalls, 0);
    expect(engine.events.single.type, ScoringEventType.wide);
  });

  test('no-ball adds runs but does not consume a legal ball', () {
    final engine = ScoringEngine();

    engine.addNoBall();

    expect(engine.score.runs, 1);
    expect(engine.score.noBallRuns, 1);
    expect(engine.score.legalBalls, 0);
    expect(engine.events.single.type, ScoringEventType.noBall);
  });

  test('no-ball can be recorded without adding runs', () {
    final engine = ScoringEngine();

    engine.addNoBall(runs: 0);

    expect(engine.score.runs, 0);
    expect(engine.score.noBallRuns, 0);
    expect(engine.score.legalBalls, 0);
    expect(engine.events.single.type, ScoringEventType.noBall);
  });

  test('undo restores the score from the remaining events', () {
    final engine = ScoringEngine();
    engine.addRun(6);
    engine.addWicket();

    engine.undo();

    expect(engine.score.runs, 6);
    expect(engine.score.wickets, 0);
    expect(engine.score.legalBalls, 1);
    expect(engine.canUndo, isTrue);
  });

  test('rejects a run outside the normal scoring range', () {
    final engine = ScoringEngine();

    expect(() => engine.addRun(7), throwsArgumentError);
  });

  test('stops adding legal deliveries after configured overs', () {
    final engine = ScoringEngine(maxOvers: 1);
    for (var index = 0; index < 6; index++) {
      engine.addRun(1);
    }

    expect(() => engine.addRun(1), throwsStateError);
    expect(engine.isInningsComplete(), isTrue);
  });
}
