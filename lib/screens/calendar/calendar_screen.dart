import 'package:flutter/material.dart';

import '../../models/match.dart';
import '../../repositories/match_repository.dart';
import '../scoring/scoring_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _repository = MatchRepository();
  late DateTime _selectedDate;
  late Future<List<CricketMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadMatches();
  }

  void _loadMatches() {
    _matchesFuture = _repository.getMatchesOnDate(_selectedDate);
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
        _loadMatches();
      });
    }
  }

  Future<void> _openMatch(CricketMatch match) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ScoringScreen(match: match)));
    if (mounted) setState(_loadMatches);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Calendar'),
        actions: [IconButton(tooltip: 'Choose date', onPressed: _chooseDate, icon: const Icon(Icons.event))],
      ),
      body: FutureBuilder<List<CricketMatch>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Could not load matches for this date.'));
          final matches = snapshot.data ?? const <CricketMatch>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(dateLabel, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (matches.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No matches on this date.')))
              else
                ...matches.map((match) => Card(child: ListTile(onTap: () => _openMatch(match), title: Text('${match.teamAName} vs ${match.teamBName}'), subtitle: Text('${match.overs} overs • ${match.status.name}'), trailing: const Icon(Icons.chevron_right)))),
            ],
          );
        },
      ),
    );
  }
}
