import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const _dbName = 'agent_app.db';
  static const _dbVersion = 5; // Incremented for commodities and campaigns

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
        numeroFiche TEXT UNIQUE NOT NULL,
        formId INTEGER,
        bundle_id TEXT,
        campagne TEXT,
        username TEXT,
        payload BLOB,
        encodedPreview TEXT,
        fieldsJson TEXT,
        image TEXT,
        status TEXT,
        submissionMethod TEXT, -- http, ussd, local
        typeTransfert TEXT,    -- ORDINAIRE, INTERIEURE
        totalParts INTEGER,
        partsSent INTEGER,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_numeroFiche ON transferts(numeroFiche)');

    await _createReferenceTables(db);
    await _createCommodityAndCampaignTables(db);
    await _createReceiptsTable(db);
  }

  // Gestion simple de la migration si la DB existait déjà
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transferts ADD COLUMN typeTransfert TEXT');
      await db.execute(
        'ALTER TABLE transferts ADD COLUMN submissionMethod TEXT',
      );
    }
    if (oldVersion < 3) {
      await _createReferenceTables(db);
    }
    if (oldVersion < 4) {
      // Migration vers numeroFiche comme clé primaire
      // Pour simplifier, on recrée la table (perte des données existantes)
      // Dans une vraie app, faire une migration plus complexe
      await db.execute('DROP TABLE IF EXISTS transferts');
      await db.execute('''
        CREATE TABLE transferts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          numeroFiche TEXT UNIQUE NOT NULL,
          formId INTEGER,
          bundle_id TEXT,
          campagne TEXT,
          username TEXT,
          payload BLOB,
          encodedPreview TEXT,
          fieldsJson TEXT,
          image TEXT,
          status TEXT,
          submissionMethod TEXT,
          typeTransfert TEXT,
          totalParts INTEGER,
          partsSent INTEGER,
          createdAt INTEGER,
          updatedAt INTEGER
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_numeroFiche ON transferts(numeroFiche)',
      );
    }
    if (oldVersion < 5) {
      await _createCommodityAndCampaignTables(db);
      await _createReceiptsTable(db);
    }
  }

  Future<void> _createCommodityAndCampaignTables(Database db) async {
    await db.execute('''\n      CREATE TABLE commodities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''\n      CREATE TABLE campaigns (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        commodity_code TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_campaign_commodity ON campaigns(commodity_code)',
    );
    await db.execute(
      'CREATE INDEX idx_campaign_active ON campaigns(is_active, status)',
    );

    await db.execute('''\n      CREATE TABLE app_preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Insert default commodity preference
    await db.insert('app_preferences', {
      'key': 'selected_commodity',
      'value': 'ANACARDE',
    });
  }

  Future<void> _createReferenceTables(Database db) async {
    await db.execute('''
      CREATE TABLE regions (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE departments (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        region_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sub_prefectures (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        department_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sectors (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        sub_prefecture_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE zds (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        sector_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE localites (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        zd_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE quarters (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        localite_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE warehouses (
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        type TEXT,
        capacity INTEGER,
        occupancy_rate REAL,
        campaign_code TEXT,
        locality TEXT,
        gps_lat REAL,
        gps_lon REAL,
        construction_date TEXT,
        status TEXT,
        is_active INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _createReceiptsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS receipts (
      numeroRecu TEXT PRIMARY KEY,
      campagne TEXT NOT NULL,
      bundleId TEXT NOT NULL,
      imagePath TEXT,
      date INTEGER,
      departement TEXT,
      typeTransfert TEXT,
      sousPrefecture TEXT,
      village TEXT,
      numeroAgrement TEXT,
      nomAcheteur TEXT,
      nomPisteur TEXT,
      contactPisteur TEXT,
      nomProducteur TEXT,
      villageProducteur TEXT,
      contactProducteur TEXT,
      nbSacsAchetes INTEGER,
      nbSacsRembourses INTEGER,
      poidsTotal REAL,
      prixUnitaire REAL,
      valeurTotale REAL,
      montantPaye REAL,
      status TEXT NOT NULL DEFAULT 'draft',
      agentId TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      updatedAt INTEGER NOT NULL
    )
  ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_receipts_status ON receipts(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_receipts_agent ON receipts(agentId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_receipts_campagne ON receipts(campagne)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_receipts_created ON receipts(createdAt)',
    );
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
