import 'dart:convert';

import 'package:sqflite/sqflite.dart';

abstract class Store {
  Future<Map<String, dynamic>> read();
  Future<void> write(Map<String, dynamic> data);
}

class LocalStore implements Store {
  Database? _db;
  Future<Database> get database async => _db ??= await openDatabase(
    '${await getDatabasesPath()}/agriflutter.db',
    version: 1,
    onCreate: (db, _) => db.execute(
      'CREATE TABLE snapshot (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)',
    ),
  );
  @override
  Future<Map<String, dynamic>> read() async {
    final rows = await (await database).query(
      'snapshot',
      where: 'id = ?',
      whereArgs: [1],
    );
    return rows.isEmpty
        ? {}
        : Map<String, dynamic>.from(
            jsonDecode(rows.first['payload'] as String) as Map,
          );
  }

  @override
  Future<void> write(Map<String, dynamic> data) async =>
      (await database).insert('snapshot', {
        'id': 1,
        'payload': jsonEncode(data),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
}

class MemoryStore implements Store {
  Map<String, dynamic> data = {};
  @override
  Future<Map<String, dynamic>> read() async => Map.from(data);
  @override
  Future<void> write(Map<String, dynamic> value) async {
    data = Map.from(value);
  }
}
