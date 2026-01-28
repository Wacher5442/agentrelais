import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../../../../core/network/dio_client.dart';

class ReceiptRemoteDataSource {
  final DioClient dioClient;
  ReceiptRemoteDataSource(this.dioClient);

  /// Convertit une image en base64
  Future<String?> _imageToBase64(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      log('Erreur conversion image en base64: $e');
      return null;
    }
  }

  /// Upload du reçu via HTTP avec l'image en base64
  Future<void> uploadReceipt({
    required String numeroRecu,
    required String campagne,
    required String bundleId,
    required Map<String, dynamic> receiptData,
    String? photoPath,
  }) async {
    // Convertir l'image en base64 si disponible
    String? imageBase64;
    if (photoPath != null && photoPath.isNotEmpty) {
      imageBase64 = await _imageToBase64(photoPath);
    }

    // Construire le payload selon le format attendu par l'API
    final payload = {
      'numeroRecu': numeroRecu,
      'campagne': campagne,
      'bundle_id': bundleId,
      'image': imageBase64, // Image en base64
      'date': receiptData['date'],
      'departement': receiptData['departement'],
      'typeTransfert': receiptData['typeTransfert'],
      'sousPrefecture': receiptData['sousPrefecture'],
      'village': receiptData['village'],
      'numeroAgrement': receiptData['numeroAgrement'],
      'nomAcheteur': receiptData['nomAcheteur'],
      'nomPisteur': receiptData['nomPisteur'],
      'contactPisteur': receiptData['contactPisteur'],
      'nomProducteur': receiptData['nomProducteur'],
      'villageProducteur': receiptData['villageProducteur'],
      'contactProducteur': receiptData['contactProducteur'],
      'nbSacsAchetes': receiptData['nbSacsAchetes'],
      'nbSacsRembourses': receiptData['nbSacsRembourses'],
      'poidsTotal': receiptData['poidsTotal'],
      'prixUnitaire': receiptData['prixUnitaire'],
      'valeurTotale': receiptData['valeurTotale'],
      'montantPaye': receiptData['montantPaye'],
    };

    final resp = await dioClient.post('/receipts', data: payload);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Échec de l\'envoi HTTP: ${resp.statusCode}');
    }

    log('Reçu $numeroRecu envoyé avec succès');
  }
}
