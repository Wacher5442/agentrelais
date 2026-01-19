import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const _dbName = 'agent_app.db';
  static const _dbVersion = 2; // Incrémenté car changement de schéma

  static Database? _database;
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transferts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        submissionId TEXT UNIQUE,
        formId INTEGER,
        payload BLOB,
        encodedPreview TEXT,
        fieldsJson TEXT,
        photoPath TEXT,
        status TEXT,
        submissionMethod TEXT, -- http, ussd, local
        typeTransfert TEXT,    -- ORDINAIRE, INTERIEURE
        totalParts INTEGER,
        partsSent INTEGER,
        agentId TEXT,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_submission ON transferts(submissionId)');
  }

  // Gestion simple de la migration si la DB existait déjà
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transferts ADD COLUMN typeTransfert TEXT');
      await db.execute(
        'ALTER TABLE transferts ADD COLUMN submissionMethod TEXT',
      );
    }
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String where,
    List<dynamic> args,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: args);
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    List<String>? columns,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      columns: columns,
    );
  }

  Future<int> delete(String table, String where, List<dynamic> args) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: args);
  }
}
