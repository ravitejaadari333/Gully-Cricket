import '../database/database_helper.dart';
import '../models/scoring_event.dart';

class ScoringEventRepository {
  ScoringEventRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> addEvent(int matchId, ScoringEvent event, {required int inningsNumber}) async {
    final database = await _databaseHelper.database;
    final values = event.toMap(matchId: matchId)
      ..remove('id')
      ..['innings_number'] = inningsNumber;
    await database.insert('scoring_events', values);
  }

  Future<List<ScoringEvent>> getEvents(int matchId, {required int inningsNumber}) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'scoring_events',
      where: 'match_id = ? AND innings_number = ?',
      whereArgs: [matchId, inningsNumber],
      orderBy: 'id ASC',
    );
    return rows.map(ScoringEvent.fromMap).toList();
  }

  Future<void> deleteLastEvent(int matchId, {required int inningsNumber}) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'scoring_events',
      columns: ['id'],
      where: 'match_id = ? AND innings_number = ?',
      whereArgs: [matchId, inningsNumber],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await database.delete('scoring_events', where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }
}