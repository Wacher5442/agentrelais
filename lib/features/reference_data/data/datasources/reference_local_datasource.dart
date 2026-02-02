import 'package:sqflite/sqflite.dart';
import '../../../../core/db/db_helper.dart';

class ReferenceLocalDataSource {
  final DbHelper dbHelper;

  ReferenceLocalDataSource(this.dbHelper);

  Future<void> saveBatch(String table, List<Map<String, dynamic>> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      final data = Map<String, dynamic>.from(item);
      if (data.containsKey('is_active') && data['is_active'] is bool) {
        data['is_active'] = (data['is_active'] as bool) ? 1 : 0;
      }

      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> clearTable(String table) async {
    final db = await dbHelper.database;
    await db.delete(table);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await dbHelper.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getByParent(
    String table,
    String parentCol,
    String parentId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      table,
      where: '$parentCol = ?',
      whereArgs: [parentId],
    );
  }
}
