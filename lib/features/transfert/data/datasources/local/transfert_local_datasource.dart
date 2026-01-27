import 'dart:convert';
import 'dart:developer';

import '../../../../../core/db/db_helper.dart';
import '../../models/transfert_model.dart';

abstract class TransfertLocalDataSource {
  Future<void> insertTransfert(TransfertModel transfert);
  Future<void> updateStatus(String numeroFiche, String status);
  Future<void> updatePartsInfo(
    String numeroFiche,
    int totalParts,
    int partsSent,
  );
  Future<List<TransfertModel>> getAllTransferts();
  Future<List<TransfertModel>> getPendingTransferts();
  Future<int> countTransfertsByStatus(List<String> statuses);
}

class TransfertLocalDataSourceImpl implements TransfertLocalDataSource {
  final DbHelper dbHelper;

  TransfertLocalDataSourceImpl(this.dbHelper);

  @override
  Future<void> insertTransfert(TransfertModel transfert) async {
    log('================ INSERT TRANSFERT (LOCAL DB) =================');

    final map = transfert.toMap();
    log(const JsonEncoder.withIndent('  ').convert(map));

    log('==============================================================');

    await dbHelper.insert('transferts', transfert.toMap());
  }

  @override
  Future<void> updateStatus(String numeroFiche, String status) async {
    await dbHelper.update(
      'transferts',
      {'status': status, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      'numeroFiche = ?',
      [numeroFiche],
    );
  }

  @override
  Future<void> updatePartsInfo(
    String numeroFiche,
    int totalParts,
    int partsSent,
  ) async {
    await dbHelper.update(
      'transferts',
      {
        'totalParts': totalParts,
        'partsSent': partsSent,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      'numeroFiche = ?',
      [numeroFiche],
    );
  }

  @override
  Future<List<TransfertModel>> getAllTransferts() async {
    final rows = await dbHelper.query('transferts', orderBy: 'createdAt DESC');
    return rows.map((row) => TransfertModel.fromMap(row)).toList();
  }

  @override
  Future<List<TransfertModel>> getPendingTransferts() async {
    final rows = await dbHelper.query(
      'transferts',
      where: 'status IN (?,?,?,?)',
      whereArgs: ['en_attente', 'draft', 'envoyé_ussd', 'echec'],
    );
    return rows.map((row) => TransfertModel.fromMap(row)).toList();
  }

  @override
  Future<int> countTransfertsByStatus(List<String> statuses) async {
    if (statuses.isEmpty) {
      // Return total count if no status filter provided
      final result = await dbHelper.query(
        'transferts',
        columns: ['COUNT(*) as count'],
      );
      return result.first['count'] as int;
    }

    final placeholders = List.filled(statuses.length, '?').join(',');
    final result = await dbHelper.query(
      'transferts',
      columns: ['COUNT(*) as count'],
      where: 'status IN ($placeholders)',
      whereArgs: statuses,
    );
    return result.first['count'] as int;
  }
}
