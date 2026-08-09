import 'dart:convert';

import 'package:analytics_sdk/analytics_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class EventQueue {
  static const _table = 'analytics_event';
  static const maxSize = 500;

  final Database _db;

  EventQueue._(this._db);

  static Future<EventQueue> create() async {
    final dir = await getApplicationCacheDirectory();
    final dbPath = p.join(dir.path, 'analytics_sdk.db');

    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT NOT NULL UNIQUE,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );

    return EventQueue._(db);
  }

  Future<void> enqueue(AnalyticsEvent event) async {
    await _db.insert(_table, {
      'event_id': event.eventId,
      'payload': jsonEncode(event.toJson()),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await _trimIfNeeded();
  }

  Future<int> length() async {
    final result = await _db.query('SELECT COUNT(*) AS c FROM $_table');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Oldest-first batch for upload
  Future<List<AnalyticsEvent>> dequeue(int count) async {
    final rows = await _db.query(_table, orderBy: 'id ASC', limit: count);

    if (rows.isEmpty) return [];

    final events = rows
        .map(
          (row) => AnalyticsEvent.fromJson(
            jsonDecode(row['payload'] as String) as Map<String, dynamic>,
          ),
        )
        .toList();

    final ids = rows.map((r) => r['id'] as int).toList();

    await _db.delete(
      _table,
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );

    return events;
  }

  /// Restore events if upload failed (keep same eventIds)
  Future<void> requeue(List<AnalyticsEvent> events) async {
    final batch = _db.batch();

    for (final event in events) {
      batch.insert(_table, {
        'event_id': event.eventId,
        'payload': jsonEncode(event.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();

    await _trimIfNeeded();
  }

  Future<void> _trimIfNeeded() async {
    final count = await length();

    if (count <= maxSize) return;

    final overflow = count - maxSize;

    await _db.rawDelete(
      '''
      DELETE FROM $_table
      WHERE id IN (
        SELECT id from $_table
        ORDER BY id ASC
        LIMIT ?
      )
    ''',
      [overflow],
    );
  }

  Future<void> close() => _db.close();
}
