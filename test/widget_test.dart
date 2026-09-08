import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:cricket_app/app/app.dart';
import 'package:cricket_app/models/match.dart';
import 'package:cricket_app/screens/scoring/scoring_screen.dart';

void main() {
  testWidgets('shows the Gully Cricket home screen after splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GullyCricketApp());
    expect(find.text('GULLY CRICKET'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(find.text('Gully Cricket'), findsOneWidget);
  });

  testWidgets('records wides and no-balls without runs when rules are off', (
    tester,
  ) async {
    const match = CricketMatch(
      teamAName: 'Team A',
      teamBName: 'Team B',
      overs: 2,
      wideEnabled: false,
      noBallEnabled: false,
      playerTrackingEnabled: false,
      mode: MatchMode.newMatch,
      battingFirstTeam: 'Team A',
    );

    await tester.pumpWidget(
      const MaterialApp(home: ScoringScreen(match: match)),
    );
    await tester.pump();

    expect(find.text('EXTRAS'), findsNothing);
    expect(find.text('Wide'), findsOneWidget);
    expect(find.text('No ball'), findsOneWidget);
    expect(find.text('Wicket'), findsOneWidget);

    await tester.ensureVisible(find.text('Wide'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wide'));
    await tester.pump();
    await tester.tap(find.text('No ball'));
    await tester.pump();

    expect(find.text('0 / 0'), findsOneWidget);
    expect(find.text('0.0 / 2.0 overs'), findsOneWidget);
    expect(find.text('WD   NB'), findsOneWidget);
  });
}
