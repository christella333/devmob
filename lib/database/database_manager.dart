import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../modele/redacteur.dart';

class DatabaseManager {
  DatabaseManager._();
  static final DatabaseManager instance = DatabaseManager._();

  static const _dbName = 'magazine_infos.db';
  static const _dbVersion = 1;
  static const _table = 'redacteurs';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, _dbName);
    _db = await openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE
        )
      ''');
      },
    );
    return _db!;
  }

  Future<List<Redacteur>> getAll() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'id DESC');
    return rows.map((e) => Redacteur.fromMap(e)).toList();
  }

  Future<int> insert(Redacteur r) async {
    final db = await database;
    return db.insert(
      _table,
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> update(Redacteur r) async {
    final db = await database;
    return db.update(_table, r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
