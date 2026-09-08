import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/match.dart';
import '../../repositories/match_repository.dart';
import '../scoring/scoring_screen.dart';

class SelectBattingTeamScreen extends StatefulWidget {
  const SelectBattingTeamScreen({super.key, required this.match});

  final CricketMatch match;

  @override
  State<SelectBattingTeamScreen> createState() => _SelectBattingTeamScreenState();
}

class _SelectBattingTeamScreenState extends State<SelectBattingTeamScreen> {
  final _manualRunsController = TextEditingController();
  final _repository = MatchRepository();
  String? _battingFirstTeam;
  MatchMode _mode = MatchMode.newMatch;
  bool _isStarting = false;

  @override
  void dispose() {
    _manualRunsController.dispose();
    super.dispose();
  }

  Future<void> _startMatch() async {
    final team = _battingFirstTeam;
    if (team == null) {
      _showMessage('Select the team batting first.');
      return;
    }

    final firstInningsRuns = int.tryParse(_manualRunsController.text.trim());
    if (_mode == MatchMode.manualFirstInnings &&
        (firstInningsRuns == null || firstInningsRuns < 0)) {
      _showMessage('Enter the manually recorded first-innings runs.');
      return;
    }

    setState(() => _isStarting = true);
    final updatedMatch = widget.match.copyWith(
      mode: _mode,
      target: _mode == MatchMode.manualFirstInnings ? firstInningsRuns! + 1 : null,
      currentInnings: _mode == MatchMode.manualFirstInnings ? 2 : 1,
      firstInningsRuns: _mode == MatchMode.manualFirstInnings ? firstInningsRuns : null,
      battingFirstTeam: team,
      status: MatchStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    try {
      await _repository.updateMatch(updatedMatch);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ScoringScreen(match: updatedMatch),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isStarting = false);
        _showMessage('Could not update the match. Please try again.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    return Scaffold(
      appBar: AppBar(title: const Text('Match Setup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('WHO IS BATTING FIRST?', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 14),
          _TeamChoice(
            name: match.teamAName,
            selected: _battingFirstTeam == match.teamAName,
            onTap: () => setState(() => _battingFirstTeam = match.teamAName),
          ),
          const SizedBox(height: 12),
          _TeamChoice(
            name: match.teamBName,
            selected: _battingFirstTeam == match.teamBName,
            onTap: () => setState(() => _battingFirstTeam = match.teamBName),
          ),
          const SizedBox(height: 30),
          Text('MATCH MODE', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<MatchMode>(
            segments: const [
              ButtonSegment(value: MatchMode.newMatch, label: Text('New match')),
              ButtonSegment(value: MatchMode.manualFirstInnings, label: Text('Manual innings')),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          ),
          if (_mode == MatchMode.manualFirstInnings) ...[
            const SizedBox(height: 18),
            TextField(
              controller: _manualRunsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'First innings runs',
                helperText: 'The chase target will be one run higher.',
              ),
            ),
          ],
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: _isStarting ? null : _startMatch,
            icon: const Icon(Icons.sports_cricket),
            label: Text(_isStarting ? 'Saving...' : 'Start match'),
          ),
        ],
      ),
    );
  }
}

class _TeamChoice extends StatelessWidget {
  const _TeamChoice({required this.name, required this.selected, required this.onTap});

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: selected ? colors.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: selected ? const Icon(Icons.check) : null,
      ),
    );
  }
}