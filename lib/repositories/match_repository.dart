import '../database/database_helper.dart';
import '../models/match.dart';

class MatchRepository {
  MatchRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<CricketMatch> createMatch(CricketMatch match) async {
    final database = await _databaseHelper.database;
    final id = await database.insert('matches', match.toMap()..remove('id'));
    return match.copyWith(id: id);
  }

  Future<void> updateMatch(CricketMatch match) async {
    final id = match.id;
    if (id == null) throw ArgumentError('A match ID is required to update a match.');

    final database = await _databaseHelper.database;
    await database.update('matches', match.toMap()..remove('id'), where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CricketMatch>> getActiveMatches() async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'matches',
      where: 'status IN (?, ?)',
      whereArgs: [MatchStatus.notStarted.name, MatchStatus.inProgress.name],
      orderBy: 'updated_at DESC',
    );
    return rows.map(CricketMatch.fromMap).toList();
  }

  Future<List<CricketMatch>> getAllMatches() async {
    final database = await _databaseHelper.database;
    final rows = await database.query('matches', orderBy: 'updated_at DESC');
    return rows.map(CricketMatch.fromMap).toList();
  }

  Future<List<CricketMatch>> getMatchesOnDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'matches',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'updated_at DESC',
    );
    return rows.map(CricketMatch.fromMap).toList();
  }

  Future<void> deleteMatch(int matchId) async {
    final database = await _databaseHelper.database;
    await database.transaction((transaction) async {
      await transaction.delete('scoring_events', where: 'match_id = ?', whereArgs: [matchId]);
      await transaction.delete('matches', where: 'id = ?', whereArgs: [matchId]);
    });
  }

  Future<void> updateLifecycle(CricketMatch match) => updateMatch(match);
}