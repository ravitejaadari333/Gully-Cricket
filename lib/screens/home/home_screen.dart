import 'package:flutter/material.dart';

import '../../models/match.dart';
import '../../repositories/match_repository.dart';
import '../../widgets/cricket_logo.dart';
import '../scoring/scoring_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _matchRepository = MatchRepository();
  late Future<List<CricketMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _reloadMatches();
  }

  void _reloadMatches() {
    _matchesFuture = _matchRepository.getAllMatches();
  }

  Future<void> _openNewMatch() async {
    await Navigator.pushNamed(context, '/create-match');
    if (mounted) setState(_reloadMatches);
  }

  Future<void> _openMatch(CricketMatch match) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => ScoringScreen(match: match)),
    );
    if (mounted) setState(_reloadMatches);
  }

  Future<void> _deleteMatch(CricketMatch match) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match?'),
        content: const Text(
          'This will delete the match and its scoring history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && match.id != null) {
      await _matchRepository.deleteMatch(match.id!);
      if (mounted) setState(_reloadMatches);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gully Cricket'),
        actions: [
          IconButton(
            tooltip: 'Match calendar',
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<CricketMatch>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text('Could not load matches.'));
          final matches = snapshot.data ?? const <CricketMatch>[];
          final active = matches
              .where((match) => match.status == MatchStatus.inProgress)
              .take(3)
              .toList();
          final today = DateTime.now();
          final todayMatches = matches.where((match) {
            final created = match.createdAt;
            return created != null &&
                created.year == today.year &&
                created.month == today.month &&
                created.day == today.day;
          }).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'YOUR SCOREBOARD',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready for the next match?',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              _ResumeCard(
                matches: active,
                onOpen: _openMatch,
                onDelete: _deleteMatch,
              ),
              const SizedBox(height: 28),
              Text(
                "TODAY'S MATCHES",
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (todayMatches.isEmpty)
                const _EmptyMatches()
              else
                ...todayMatches
                    .take(10)
                    .map(
                      (match) => _MatchCard(
                        match: match,
                        onTap: _openMatch,
                        onDelete: _deleteMatch,
                      ),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewMatch,
        icon: const Icon(Icons.add),
        label: const Text('New match'),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.matches,
    required this.onOpen,
    required this.onDelete,
  });
  final List<CricketMatch> matches;
  final Future<void> Function(CricketMatch) onOpen;
  final Future<void> Function(CricketMatch) onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_outline, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  'RESUME MATCH',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (matches.isEmpty) ...[
              Text(
                'No active matches',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Your unfinished matches will appear here.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ] else
              ...matches.map(
                (match) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${match.teamAName} vs ${match.teamBName}'),
                  subtitle: Text('${match.overs} overs'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Delete match',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(match),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => onOpen(match),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.onTap,
    required this.onDelete,
  });
  final CricketMatch match;
  final Future<void> Function(CricketMatch) onTap;
  final Future<void> Function(CricketMatch) onDelete;

  @override
  Widget build(BuildContext context) {
    final createdAt = match.createdAt;
    final createdTime = createdAt == null
        ? null
        : TimeOfDay.fromDateTime(createdAt).format(context);
    final subtitle = createdTime == null
        ? match.status.name
        : '${match.status.name} • $createdTime';

    return Card(
      child: ListTile(
        onTap: () => onTap(match),
        title: Text('${match.teamAName} vs ${match.teamBName}'),
        subtitle: Text(subtitle),
        trailing: IconButton(
          tooltip: 'Delete match',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => onDelete(match),
        ),
      ),
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          const CricketLogo(size: 54, muted: true),
          const SizedBox(height: 12),
          Text(
            'No matches today',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first match to get started.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
