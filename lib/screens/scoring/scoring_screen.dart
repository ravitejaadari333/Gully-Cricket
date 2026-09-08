import 'package:flutter/material.dart';

import '../../models/match.dart';
import '../../models/scoring_event.dart';
import '../../repositories/match_repository.dart';
import '../../repositories/scoring_event_repository.dart';
import '../../services/scoring_engine.dart';
import '../match_result/match_result_screen.dart';

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key, required this.match});

  final CricketMatch match;

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  late final ScoringEngine _engine;
  final _eventRepository = ScoringEventRepository();
  final _matchRepository = MatchRepository();
  bool _isLoading = true;
  bool _completionHandled = false;

  int get _inningsNumber => widget.match.currentInnings;
  String get _battingTeam => _inningsNumber == 1
      ? (widget.match.battingFirstTeam ?? widget.match.teamAName)
      : (widget.match.battingFirstTeam == widget.match.teamAName
            ? widget.match.teamBName
            : widget.match.teamAName);

  @override
  void initState() {
    super.initState();
    _engine = ScoringEngine(maxOvers: widget.match.overs);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final matchId = widget.match.id;
    if (matchId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final events = await _eventRepository.getEvents(
        matchId,
        inningsNumber: _inningsNumber,
      );
      if (mounted) {
        setState(() {
          _engine.replaceEvents(events);
          _isLoading = false;
        });
        if (_isComplete) await _finishInnings();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Could not restore the saved score.');
      }
    }
  }

  bool get _isComplete => _engine.isInningsComplete(
    target: _inningsNumber == 2 ? widget.match.target : null,
  );

  Future<void> _score(void Function() action) async {
    if (_isLoading || _completionHandled) return;
    ScoringEvent? addedEvent;
    try {
      setState(() {
        final before = _engine.events.length;
        action();
        if (_engine.events.length > before) addedEvent = _engine.events.last;
      });
      final matchId = widget.match.id;
      if (addedEvent != null && matchId != null) {
        await _eventRepository.addEvent(
          matchId,
          addedEvent!,
          inningsNumber: _inningsNumber,
        );
      }
      if (_isComplete) await _finishInnings();
    } on ArgumentError catch (error) {
      _showMessage(error.message.toString());
    } on StateError catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Could not save the scoring action.');
    }
  }

  Future<void> _undo() async {
    if (_isLoading || !_engine.canUndo) return;
    setState(_engine.undo);
    final matchId = widget.match.id;
    if (matchId != null) {
      try {
        await _eventRepository.deleteLastEvent(
          matchId,
          inningsNumber: _inningsNumber,
        );
      } catch (_) {
        _showMessage('Could not save the undo action.');
      }
    }
  }

  Future<void> _finishInnings() async {
    if (_completionHandled || widget.match.id == null) return;
    _completionHandled = true;
    final score = _engine.score;
    if (_inningsNumber == 1) {
      final secondInningsMatch = widget.match.copyWith(
        currentInnings: 2,
        firstInningsRuns: score.runs,
        target: score.runs + 1,
        status: MatchStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      if (!mounted) return;
      final shouldStartSecondInnings = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('First innings complete'),
          content: Text(
            '$_battingTeam scored ${score.runs}/${score.wickets}. Target: ${score.runs + 1}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Review'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start second innings'),
            ),
          ],
        ),
      );
      if (shouldStartSecondInnings != true) {
        if (mounted) setState(() => _completionHandled = false);
        return;
      }
      await _matchRepository.updateLifecycle(secondInningsMatch);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ScoringScreen(match: secondInningsMatch),
          ),
        );
      }
    } else {
      final firstRuns =
          widget.match.firstInningsRuns ?? ((widget.match.target ?? 1) - 1);
      final target = widget.match.target ?? firstRuns + 1;
      final winner = score.runs >= target
          ? _battingTeam
          : score.runs == firstRuns
          ? null
          : widget.match.battingFirstTeam;
      final result = winner == null
          ? 'Match tied'
          : score.runs >= target
          ? '$winner won by ${10 - score.wickets} wickets'
          : '$winner won by ${firstRuns - score.runs} runs';
      if (!mounted) return;
      final shouldFinishMatch = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(
            score.runs >= target ? 'Target reached' : 'Second innings complete',
          ),
          content: Text(
            '$_battingTeam scored ${score.runs}/${score.wickets}. $result.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Review'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Finish match'),
            ),
          ],
        ),
      );
      if (shouldFinishMatch != true) {
        if (mounted) setState(() => _completionHandled = false);
        return;
      }
      final completedMatch = widget.match.copyWith(
        status: MatchStatus.completed,
        winner: winner,
        resultText: result,
        updatedAt: DateTime.now(),
      );
      await _matchRepository.updateLifecycle(completedMatch);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MatchResultScreen(
            match: completedMatch,
            score: ScoreResult(
              title: result,
              detail: '${widget.match.teamAName} vs ${widget.match.teamBName}',
            ),
          ),
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final score = _engine.score;
    final colors = Theme.of(context).colorScheme;
    final extrasEnabled =
        widget.match.wideEnabled || widget.match.noBallEnabled;
    final grouped = <int, List<ScoringEvent>>{};
    for (final event in _engine.events) {
      grouped.putIfAbsent(event.overNumber, () => []).add(event);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('$_battingTeam • Innings $_inningsNumber'),
        actions: [
          IconButton(
            tooltip: 'Undo last action',
            onPressed: _engine.canUndo && !_isLoading && !_completionHandled
                ? _undo
                : null,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Card(
            color: colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _battingTeam,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${score.runs} / ${score.wickets}',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${score.oversDisplay} / ${widget.match.overs}.0 overs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_inningsNumber == 2)
                    Text(
                      'Target: ${widget.match.target}  •  Need: ${((widget.match.target ?? 0) - score.runs).clamp(0, 999)}',
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 24),
          Text('RUNS', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var runs = 1; runs <= 6; runs++)
                _RunButton(
                  runs: runs,
                  onPressed: _isLoading || _completionHandled
                      ? null
                      : () => _score(() => _engine.addRun(runs)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _isLoading || _completionHandled
                      ? null
                      : () => _score(_engine.addWicket),
                  icon: const Icon(Icons.close),
                  label: const Text('Wicket'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _isLoading || _completionHandled
                      ? null
                      : () => _score(
                          () => _engine.addWide(
                            runs: widget.match.wideEnabled ? 1 : 0,
                          ),
                        ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Wide'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _isLoading || _completionHandled
                      ? null
                      : () => _score(
                          () => _engine.addNoBall(
                            runs: widget.match.noBallEnabled ? 1 : 0,
                          ),
                        ),
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('No ball'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('OVER HISTORY', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          if (grouped.isEmpty)
            Text(
              'Score the first delivery to begin.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ...grouped.entries.toList().reversed.map(
            (entry) => Card(
              child: ListTile(
                title: Text('Over ${entry.key}'),
                subtitle: Text(entry.value.map(_eventLabel).join('   ')),
                trailing: Text(
                  '${entry.value.fold<int>(0, (sum, event) => sum + event.runs)} runs',
                ),
              ),
            ),
          ),
          if (extrasEnabled) ...[
            const SizedBox(height: 18),
            Text('EXTRAS', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('Wides: ${score.wideRuns}    No-balls: ${score.noBallRuns}'),
          ],
        ],
      ),
    );
  }

  String _eventLabel(ScoringEvent event) => switch (event.type) {
    ScoringEventType.run => '${event.runs}',
    ScoringEventType.wicket => 'W',
    ScoringEventType.wide => 'WD',
    ScoringEventType.noBall => 'NB',
  };
}

class _RunButton extends StatelessWidget {
  const _RunButton({required this.runs, required this.onPressed});
  final int runs;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Text(
      '$runs',
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
