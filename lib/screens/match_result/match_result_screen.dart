import 'package:flutter/material.dart';

import '../../models/match.dart';
import 'innings_summary_screen.dart';

class MatchResultScreen extends StatelessWidget {
  const MatchResultScreen({super.key, required this.match, required this.score});

  final CricketMatch match;
  final ScoreResult score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_outlined, size: 72),
              const SizedBox(height: 20),
              Text(score.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(score.detail, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => InningsSummaryScreen(match: match),
                  ),
                ),
                icon: const Icon(Icons.summarize_outlined),
                label: const Text('Summary'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false), icon: const Icon(Icons.home), label: const Text('Back to home')),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreResult {
  const ScoreResult({required this.title, required this.detail});
  final String title;
  final String detail;
}