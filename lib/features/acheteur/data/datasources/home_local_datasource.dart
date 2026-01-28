import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../../core/db/db_helper.dart';
import '../../../../../core/models/recu_model.dart';
import '../../domain/entities/home_stats.dart';

abstract class IHomeLocalDataSource {
  Future<HomeStats> getStats();
  Future<List<Recu>> getReceipts({String? search, String? filter});
}

class HomeLocalDataSourceImpl implements IHomeLocalDataSource {
  final DbHelper dbHelper;

  HomeLocalDataSourceImpl({required this.dbHelper});

  // Helper pour compter les statuts
  Future<int> _getCount(Database db, String status) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM receipts WHERE status = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<HomeStats> getStats() async {
    final db = await dbHelper.database;
    // Vos statuts sont 'Validé', 'En attente', 'Rejeté'
    final valides = await _getCount(db, 'Validé');
    final enAttente = await _getCount(db, 'En attente');
    final reclassifyes = await _getCount(db, 'Rejeté');

    return HomeStats(
      valides: valides,
      enAttente: enAttente,
      reclassifyes: reclassifyes,
    );
  }

  @override
  Future<List<Recu>> getReceipts({String? search, String? filter}) async {
    final db = await dbHelper.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    // Gérer le filtre (Status)
    if (filter != null &&
        filter.isNotEmpty &&
        filter != "Tous les statuts" &&
        filter != "Tous les magasins") {
      if (['Validé', 'En attente', 'Rejeté'].contains(filter)) {
        whereClauses.add('status = ?');
        whereArgs.add(filter);
      }
    }

    // Gérer la recherche
    if (search != null && search.isNotEmpty) {
      // CORRIGÉ: Utilise les clés JSON standardisées
      whereClauses.add('(fieldsJson LIKE ? OR fieldsJson LIKE ?)');
      whereArgs.add('%"nomProducteur":"%$search%');
      whereArgs.add('%"numeroRecu":"%$search%');
    }

    final String? whereStatement = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'receipts',
      where: whereStatement,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC', // Les plus récents en premier
    );

    // Convertir les Map de la DB en objets Recu
    return maps.map((row) {
      final fieldsJson = row['fieldsJson'] as String? ?? '{}';
      final Map<String, dynamic> jsonData = jsonDecode(fieldsJson);

      // Ajoute le statut et l'image du 'row' principal
      jsonData['status'] = row['status'];
      jsonData['image'] =
          row['photoPath']; // Assumant que Recu.fromJson gère 'image'

      return Recu.fromJson(jsonData);
    }).toList();
  }
}
