import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/match.dart';
import '../../repositories/match_repository.dart';
import '../select_batting_team/select_batting_team_screen.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  static final _teamNamePattern = RegExp(r'^[a-zA-Z0-9 ]+$');

  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController(text: 'Team A');
  final _teamBController = TextEditingController(text: 'Team B');
  final _oversController = TextEditingController(text: '10');
  final _repository = MatchRepository();

  bool _wideEnabled = true;
  bool _noBallEnabled = true;
  bool _playerTrackingEnabled = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _oversController.dispose();
    super.dispose();
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final match = CricketMatch(
      teamAName: _teamAController.text.trim(),
      teamBName: _teamBController.text.trim(),
      overs: int.parse(_oversController.text.trim()),
      wideEnabled: _wideEnabled,
      noBallEnabled: _noBallEnabled,
      playerTrackingEnabled: _playerTrackingEnabled,
      mode: MatchMode.newMatch,
      status: MatchStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final savedMatch = await _repository
          .createMatch(match)
          .timeout(const Duration(seconds: 10));
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => SelectBattingTeamScreen(match: savedMatch),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the match. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Match')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'MATCH DETAILS',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            _textField(
              _teamAController,
              'Team A',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
              validator: _validateTeamName,
            ),
            const SizedBox(height: 14),
            _textField(
              _teamBController,
              'Team B',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
              validator: _validateTeamName,
            ),
            const SizedBox(height: 14),
            _textField(
              _oversController,
              'Number of overs',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final overs = int.tryParse(value?.trim() ?? '');
                return overs == null || overs < 1
                    ? 'Enter at least 1 over'
                    : null;
              },
            ),
            const SizedBox(height: 28),
            Text(
              'SCORING RULES',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wide balls'),
              subtitle: const Text('Add one run when Wide is recorded'),
              value: _wideEnabled,
              onChanged: (value) => setState(() => _wideEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('No-balls'),
              subtitle: const Text('Add one run when No ball is recorded'),
              value: _noBallEnabled,
              onChanged: (value) => setState(() => _noBallEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Track players'),
              subtitle: const Text('Add batsman and bowler statistics later'),
              value: _playerTrackingEnabled,
              onChanged: (value) =>
                  setState(() => _playerTrackingEnabled = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveMatch,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_isSaving ? 'Saving...' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  String? _validateTeamName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Required';
    if (!_teamNamePattern.hasMatch(name)) {
      return 'Use letters, numbers, and spaces only';
    }
    return null;
  }
}
