import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'gully_cricket.db';
  static const _databaseVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: (database, version) async {
        await _createMatchesTable(database);
        await _createScoringEventsTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createScoringEventsTable(database);
        if (oldVersion < 4) {
          await _addMatchLifecycleColumns(database);
          if (oldVersion >= 2) {
            await _addColumnIfMissing(
              database,
              'scoring_events',
              'innings_number',
              'INTEGER NOT NULL DEFAULT 1',
            );
          }
        }
      },
    );
    return _database!;
  }

  static Future<void> _createMatchesTable(Database database) {
    return database.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_a_name TEXT NOT NULL,
        team_b_name TEXT NOT NULL,
        overs INTEGER NOT NULL,
        wide_enabled INTEGER NOT NULL,
        no_ball_enabled INTEGER NOT NULL,
        player_tracking_enabled INTEGER NOT NULL,
        match_mode TEXT NOT NULL,
        target INTEGER,
        batting_first_team TEXT,
        current_innings INTEGER NOT NULL DEFAULT 1,
        first_innings_runs INTEGER,
        winner TEXT,
        result_text TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createScoringEventsTable(Database database) {
    return database.execute('''
      CREATE TABLE scoring_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        over_number INTEGER NOT NULL,
        ball_number INTEGER NOT NULL,
        event_type TEXT NOT NULL,
        runs INTEGER NOT NULL,
        legal_ball INTEGER NOT NULL,
        wide_runs INTEGER NOT NULL,
        no_ball_runs INTEGER NOT NULL,
        wicket INTEGER NOT NULL,
        innings_number INTEGER NOT NULL DEFAULT 1,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (match_id) REFERENCES matches (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _addMatchLifecycleColumns(Database database) async {
    await _addColumnIfMissing(
      database,
      'matches',
      'current_innings',
      'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      database,
      'matches',
      'first_innings_runs',
      'INTEGER',
    );
    await _addColumnIfMissing(database, 'matches', 'winner', 'TEXT');
    await _addColumnIfMissing(database, 'matches', 'result_text', 'TEXT');
  }

  static Future<void> _addColumnIfMissing(
    Database database,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((entry) => entry['name'] == column);
    if (!exists) {
      await database.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }
}
