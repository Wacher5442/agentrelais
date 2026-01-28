import 'dart:developer';

import '../../../../core/db/db_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/local/receipt_local_datasource.dart';
import '../datasources/remote/receipt_remote_datasource.dart';
import '../models/receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final DbHelper dbHelper;
  final ReceiptLocalDataSource localDataSource;
  final ReceiptRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReceiptRepositoryImpl({
    required this.dbHelper,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<SubmissionResult> submitReceipt(ReceiptEntity receipt) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Créer le bundle_id (numeroRecu + numeroRecu pour l'exemple)
    final bundleId = '${receipt.numeroRecu}${receipt.numeroRecu}';

    // 1. Sauvegarder en local avec statut 'draft'
    final receiptModel = ReceiptModel(
      numeroRecu: receipt.numeroRecu,
      campagne: receipt.campagne,
      bundleId: bundleId,
      imagePath: receipt.photoPath,
      date: DateTime.now(),
      departement: receipt.fields['departement'] as String?,
      typeTransfert: receipt.fields['typeTransfert'] as String?,
      sousPrefecture: receipt.fields['sousPrefecture'] as String?,
      village: receipt.fields['village'] as String?,
      numeroAgrement: receipt.fields['numeroAgrement'] as String?,
      nomAcheteur: receipt.fields['nomAcheteur'] as String?,
      nomPisteur: receipt.fields['nomPisteur'] as String?,
      contactPisteur: receipt.fields['contactPisteur'] as String?,
      nomProducteur: receipt.fields['nomProducteur'] as String?,
      villageProducteur: receipt.fields['villageProducteur'] as String?,
      contactProducteur: receipt.fields['contactProducteur'] as String?,
      nbSacsAchetes: receipt.fields['nbSacsAchetes'] as int?,
      nbSacsRembourses: receipt.fields['nbSacsRembourses'] as int?,
      poidsTotal: receipt.fields['poidsTotal'] as double?,
      prixUnitaire: receipt.fields['prixUnitaire'] as double?,
      valeurTotale: receipt.fields['valeurTotale'] as double?,
      montantPaye: receipt.fields['montantPaye'] as double?,
      status: ReceiptStatus.draft,
      agentId: receipt.agentId,
      createdAt: now,
      updatedAt: now,
    );

    await localDataSource.insertReceipt(receiptModel);
    log('Reçu ${receipt.numeroRecu} sauvegardé localement');

    // 2. Vérifier la disponibilité du serveur
    final isConnected = !(await networkInfo.isConnected);

    // 3. Si le serveur est disponible, tenter l'envoi HTTP
    if (isConnected) {
      try {
        await remoteDataSource.uploadReceipt(
          numeroRecu: receipt.numeroRecu,
          campagne: receipt.campagne,
          bundleId: bundleId,
          receiptData: receipt.fields,
          photoPath: receipt.photoPath,
        );

        // Mise à jour du statut en cas de succès
        await localDataSource.updateStatus(
          receipt.numeroRecu,
          ReceiptStatus.synced,
        );

        log('Reçu ${receipt.numeroRecu} synchronisé avec succès');

        return SubmissionResult(
          numeroRecu: receipt.numeroRecu,
          success: true,
          message: 'Reçu envoyé avec succès',
        );
      } catch (e) {
        log('Échec de l\'envoi HTTP: $e');

        // Mise à jour du statut en cas d'échec
        await localDataSource.updateStatus(
          receipt.numeroRecu,
          ReceiptStatus.pending,
        );

        return SubmissionResult(
          numeroRecu: receipt.numeroRecu,
          success: false,
          message:
              'Reçu sauvegardé localement. Sera synchronisé ultérieurement.',
        );
      }
    } else {
      // Serveur non disponible
      await localDataSource.updateStatus(
        receipt.numeroRecu,
        ReceiptStatus.pending,
      );

      log('Serveur non disponible, reçu en attente de synchronisation');

      return SubmissionResult(
        numeroRecu: receipt.numeroRecu,
        success: false,
        message: 'Serveur non disponible. Reçu sauvegardé localement.',
      );
    }
  }

  @override
  Future<int> syncPendingReceipts() async {
    // Récupérer tous les reçus en attente
    final pendingReceipts = await localDataSource.getPending();

    if (pendingReceipts.isEmpty) {
      log('Aucun reçu en attente de synchronisation');
      return 0;
    }

    log('${pendingReceipts.length} reçu(s) en attente de synchronisation');

    int syncedCount = 0;
    for (final receipt in pendingReceipts) {
      try {
        await remoteDataSource.uploadReceipt(
          numeroRecu: receipt.numeroRecu,
          campagne: receipt.campagne,
          bundleId: receipt.bundleId,
          receiptData: receipt.toApiJson(),
          photoPath: receipt.imagePath,
        );

        await localDataSource.updateStatus(
          receipt.numeroRecu,
          ReceiptStatus.synced,
        );

        syncedCount++;
        log('Reçu ${receipt.numeroRecu} synchronisé');
      } catch (e) {
        log('Échec synchronisation reçu ${receipt.numeroRecu}: $e');

        await localDataSource.updateStatus(
          receipt.numeroRecu,
          ReceiptStatus.failed,
        );
      }
    }

    log(
      'Synchronisation terminée: $syncedCount/${pendingReceipts.length} reçu(s) synchronisé(s)',
    );
    return syncedCount;
  }

  @override
  Future<List<ReceiptEntity>> getAllReceipts() async {
    final models = await localDataSource.getAll();
    return models.map((m) => _modelToEntity(m)).toList();
  }

  @override
  Future<ReceiptEntity?> getReceiptByNumero(String numeroRecu) async {
    final model = await localDataSource.getByNumeroRecu(numeroRecu);
    if (model == null) return null;
    return _modelToEntity(model);
  }

  ReceiptEntity _modelToEntity(ReceiptModel model) {
    return ReceiptEntity(
      numeroRecu: model.numeroRecu,
      campagne: model.campagne,
      fields: model.toApiJson(),
      agentId: model.agentId,
      photoPath: model.imagePath,
      status: model.status,
    );
  }
}
