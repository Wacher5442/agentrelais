import 'package:agent_relais/core/db/db_helper.dart';
import '../../models/receipt_model.dart';

class ReceiptLocalDataSource {
  final DbHelper dbHelper;
  ReceiptLocalDataSource(this.dbHelper);

  Future<void> insertReceipt(ReceiptModel r) async {
    await dbHelper.insert('receipts', r.toMap());
  }

  Future<void> updateStatus(String numeroRecu, String status) async {
    await dbHelper.update(
      'receipts',
      {'status': status, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      'numeroRecu = ?',
      [numeroRecu],
    );
  }

  Future<List<ReceiptModel>> getPending() async {
    final rows = await dbHelper.query(
      'receipts',
      where: 'status IN (?,?)',
      whereArgs: ['en_attente', 'draft'],
    );
    return rows.map((r) => ReceiptModel.fromMap(r)).toList();
  }

  Future<List<ReceiptModel>> getAll() async {
    final rows = await dbHelper.query('receipts');
    return rows.map((r) => ReceiptModel.fromMap(r)).toList();
  }

  Future<ReceiptModel?> getByNumeroRecu(String numeroRecu) async {
    final rows = await dbHelper.query(
      'receipts',
      where: 'numeroRecu = ?',
      whereArgs: [numeroRecu],
    );
    if (rows.isEmpty) return null;
    return ReceiptModel.fromMap(rows.first);
  }

  Future<void> deleteReceipt(String numeroRecu) async {
    await dbHelper.delete('receipts', 'numeroRecu = ?', [numeroRecu]);
  }
}
