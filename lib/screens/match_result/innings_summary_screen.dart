import 'package:flutter/material.dart';

import '../../models/match.dart';
import '../../models/scoring_event.dart';
import '../../repositories/scoring_event_repository.dart';
import '../../services/scoring_engine.dart';

class InningsSummaryScreen extends StatefulWidget {
  const InningsSummaryScreen({super.key, required this.match});

  final CricketMatch match;

  @override
  State<InningsSummaryScreen> createState() => _InningsSummaryScreenState();
}

class _InningsSummaryScreenState extends State<InningsSummaryScreen> {
  final _repository = ScoringEventRepository();
  late Future<List<_InningsData>> _dataFuture;

  String get _firstTeam => widget.match.battingFirstTeam ?? widget.match.teamAName;
  String get _secondTeam => _firstTeam == widget.match.teamAName ? widget.match.teamBName : widget.match.teamAName;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<_InningsData>> _loadData() async {
    final matchId = widget.match.id;
    if (matchId == null) return const [_InningsData.empty(), _InningsData.empty()];
    final firstEvents = await _repository.getEvents(matchId, inningsNumber: 1);
    final secondEvents = await _repository.getEvents(matchId, inningsNumber: 2);
    final firstSummary = widget.match.mode == MatchMode.manualFirstInnings
        ? ScoreSummary(runs: widget.match.firstInningsRuns ?? 0, wickets: 0, legalBalls: 0, wideRuns: 0, noBallRuns: 0)
        : ScoringEngine(maxOvers: widget.match.overs, initialEvents: firstEvents).score;
    final secondSummary = ScoringEngine(maxOvers: widget.match.overs, initialEvents: secondEvents).score;
    return [_InningsData(firstSummary, firstEvents), _InningsData(secondSummary, secondEvents)];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Match Summary'), bottom: const TabBar(tabs: [Tab(text: '1st Innings'), Tab(text: '2nd Innings')])),
        body: FutureBuilder<List<_InningsData>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError || snapshot.data == null) return const Center(child: Text('Could not load match summary.'));
            final data = snapshot.data!;
            return TabBarView(children: [
              _InningsTab(teamName: _firstTeam, data: data[0], manual: widget.match.mode == MatchMode.manualFirstInnings, target: widget.match.target),
              _InningsTab(teamName: _secondTeam, data: data[1]),
            ]);
          },
        ),
      ),
    );
  }
}

class _InningsData {
  const _InningsData(this.summary, this.events);
  const _InningsData.empty() : summary = const ScoreSummary(runs: 0, wickets: 0, legalBalls: 0, wideRuns: 0, noBallRuns: 0), events = const [];
  final ScoreSummary summary;
  final List<ScoringEvent> events;
}

class _InningsTab extends StatelessWidget {
  const _InningsTab({required this.teamName, required this.data, this.manual = false, this.target});
  final String teamName;
  final _InningsData data;
  final bool manual;
  final int? target;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(teamName, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text('${summary.runs}/${summary.wickets}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)), Text(manual ? 'First innings manually entered' : '${summary.oversDisplay} overs', style: Theme.of(context).textTheme.titleMedium)]))),
        const SizedBox(height: 16),
        if (manual)
          _SummaryRow(label: 'Target', value: '${target ?? summary.runs + 1}')
        else ...[
          Text('OVER HISTORY', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._overCards(context),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Wide runs', value: '${summary.wideRuns}'),
          _SummaryRow(label: 'No-ball runs', value: '${summary.noBallRuns}'),
        ],
      ],
    );
  }

  List<Widget> _overCards(BuildContext context) {
    final overs = <int, List<ScoringEvent>>{};
    for (final event in data.events) {
      overs.putIfAbsent(event.overNumber, () => []).add(event);
    }
    return overs.entries.toList().reversed.map((entry) {
      final runs = entry.value.fold<int>(0, (total, event) => total + event.runs);
      return Card(child: ListTile(title: Text('Over ${entry.key}'), subtitle: Text(entry.value.map(_eventLabel).join('   ')), trailing: Text('$runs runs')));
    }).toList();
  }

  String _eventLabel(ScoringEvent event) => switch (event.type) {
        ScoringEventType.run => '${event.runs}',
        ScoringEventType.wicket => 'W',
        ScoringEventType.wide => 'WD',
        ScoringEventType.noBall => 'NB',
      };
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium)));
}
