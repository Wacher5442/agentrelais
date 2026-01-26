import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/ussd_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/tlv/tlv_field_mappings.dart';
import '../../../../core/tlv/tlv_protocol.dart';
import '../../../../core/tlv/tlv_splitter.dart';
import '../../../../core/utils/ussd_transport.dart';
import '../../domain/entities/transfert_entity.dart';
import '../../domain/repositories/transfert_repository.dart';
import '../datasources/local/transfert_local_datasource.dart';
import '../datasources/remote/transfert_remote_datasource.dart';
import '../models/transfert_model.dart';

class TransfertRepositoryImpl implements TransfertRepository {
  final TransfertLocalDataSource localDataSource;
  final TransfertRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final UssdTransport ussdTransport;

  final int _protocolVer = 0x01;
  final TlvEncoderType _encoderType = TlvEncoderType.base32;
  final int _ussdLimit = USSD_CHAR_LIMIT;

  // --- CONFIGURATION USSD FIXE (HARDCODED) ---
  // On ne garde que l'essentiel pour l'USSD afin de limiter le nombre de Session
  final List<String> _ussdFieldsWhitelist = [
    'typeTransfert',
    'numeroFiche',
    'sticker',
    'date',
    'sousPrefecture',
    'destinationVille',
    'codeAcheteur',
    'nomMagasin',
    'sacs',
    'poids',
    'contactTransporteur',
    'immatriculation',
  ];

  TransfertRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.ussdTransport,
  });

  @override
  Future<Either<Failure, List<TransfertEntity>>> getTransferts() async {
    try {
      final models = await localDataSource.getAllTransferts();
      return Right(models);
    } catch (e) {
      return Left(CacheFailure("Erreur récupération: $e"));
    }
  }

  @override
  Future<Either<Failure, SubmissionResult>> submitTransfert({
    required TransfertEntity transfert,
    required bool forceUssd,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final fieldsMap = transfert.toFieldsJson();
      final fieldsJson = jsonEncode(fieldsMap);

      // 1. Préparer les champs selon le mode d'envoi
      // Si USSD : on utilise la liste blanche fixe. Sinon : tous les champs.
      final isActuallyUssd = forceUssd || !(await networkInfo.isConnected);

      final tlvFields = TlvFieldMappings.mapFromDto(
        fieldsMap,
        transfert.username,
        transfert.campagne,
        transfert.receipts.length.toString(),
        keysToKeep: isActuallyUssd ? _ussdFieldsWhitelist : null,
      );

      final fullMessage = buildMessage(
        ver: _protocolVer,
        formId: transfert.formId,
        totalParts: 1,
        partIndex: 1,
        tlvFields: tlvFields,
      );

      final encodedPreview = encodeBytes(fullMessage, _encoderType);

      // 2. Sauvegarde locale systématique
      final model = TransfertModel(
        numeroFiche: transfert.numeroFiche,
        formId: transfert.formId,
        status: 'draft',
        submissionMethod: isActuallyUssd ? 'ussd' : 'http',
        username: transfert.username,
        bundleId: transfert.bundleId,
        campagne: transfert.campagne,
        createdAt: now,
        updatedAt: now,
        payload: fullMessage,
        encodedPreview: encodedPreview,
        fieldsJson: fieldsJson,
        totalParts: 1,
        partsSent: 0,
        typeTransfert: transfert.typeTransfert,
        sticker: transfert.sticker,
        receipts: transfert.receipts,
        image: transfert.image,
      );

      await localDataSource.insertTransfert(model);

      // 3. Tentative HTTP (si non forcé USSD et internet dispo)
      if (!forceUssd && await networkInfo.isConnected) {
        try {
          // NEW: Get presigned URL for transfer data
          final url = await remoteDataSource.getUploadUrl(
            'Fiche de transfert ${transfert.numeroFiche}',
            transfert.username,
          );

          // NEW: Submit transfer data separately
          final Map<String, dynamic> httpFields = Map.from(fieldsMap);
          httpFields.remove('receipts');

          // Convert main image to base64 if it exists
          if (transfert.image != null && transfert.image!.isNotEmpty) {
            final imageFile = File(transfert.image!);
            if (await imageFile.exists()) {
              final bytes = await imageFile.readAsBytes();
              httpFields['image'] = base64Encode(bytes);
              log('Main image converted to Base64 (${bytes.length} bytes)');
            }
          }

          final transferPayload = {
            "form_id": transfert.formId,
            "fields": httpFields,
          };

          await remoteDataSource.uploadTransfert(
            url: url,
            payload: transferPayload,
          );

          // NEW: Submit each receipt separately
          for (var receipt in transfert.receipts) {
            String base64Image = "";

            if (receipt.imagePath.isNotEmpty) {
              final file = File(receipt.imagePath);

              if (await file.exists()) {
                final bytes = await file.readAsBytes();

                // Taille du fichier
                final int sizeInBytes = bytes.length;
                final double sizeInKB = sizeInBytes / 1024;
                final double sizeInMB = sizeInKB / 1024;

                log(
                  'Receipt ${receipt.receiptNumber} | '
                  'File size: ${sizeInBytes} bytes '
                  '(${sizeInKB.toStringAsFixed(2)} KB / '
                  '${sizeInMB.toStringAsFixed(2)} MB)',
                  name: 'UPLOAD_RECEIPT',
                );

                base64Image = base64Encode(bytes);

                // Taille après Base64
                final int base64Size = base64Image.length;
                log(
                  'Receipt ${receipt.receiptNumber} | '
                  'Base64 size: $base64Size chars',
                  name: 'UPLOAD_RECEIPT',
                );
              } else {
                log(
                  'Receipt ${receipt.receiptNumber} | File not found',
                  level: 900,
                  name: 'UPLOAD_RECEIPT',
                );
              }
            }

            // Get separate presigned URL for each receipt
            final receiptUrl = await remoteDataSource.getUploadUrl(
              '${transfert.numeroFiche}_receipt_${receipt.receiptNumber}',
              transfert.username,
            );

            final receiptPayload = {
              "form_id": transfert.formId,
              "fields": {
                "bundle_id": transfert.bundleId,
                "numeroRecu": receipt.receiptNumber,
                "image": base64Image,
                "campagne": transfert.campagne,
              },
            };

            await remoteDataSource.uploadTransfert(
              url: receiptUrl,
              payload: receiptPayload,
            );
          }

          await localDataSource.updateStatus(
            transfert.numeroFiche,
            'synchronisé',
          );
          return Right(
            SubmissionResult(
              submissionId: transfert.numeroFiche,
              viaHttp: true,
            ),
          );
        } catch (e) {
          log("Échec HTTP: $e. Basculement USSD.");
          print(
            "DEBUG: HTTP Failure: $e",
          ); // Add print for test output visibility
        }
      }

      // 4. Envoi USSD (Fallback ou Forcé)
      if (encodedPreview.length <= _ussdLimit) {
        final success = await ussdTransport.sendPart(encodedPreview);
        final status = success ? 'envoyé_ussd' : 'echec';
        await localDataSource.updateStatus(transfert.numeroFiche, status);
        await localDataSource.updatePartsInfo(
          transfert.numeroFiche,
          1,
          success ? 1 : 0,
        );

        if (!success) return Left(ServerFailure("Échec envoi USSD"));
        return Right(
          SubmissionResult(
            submissionId: transfert.numeroFiche,
            viaHttp: false,
            totalUssdParts: 1,
          ),
        );
      } else {
        // Multipart USSD
        final parts = splitFieldsByEncodedLimit(
          allFields: tlvFields,
          ver: _protocolVer,
          formId: transfert.formId,
          limitChars: _ussdLimit,
          encoderType: _encoderType,
        );

        int sentCount = 0;
        for (int i = 0; i < parts.length; i++) {
          final partMsg = buildMessage(
            ver: _protocolVer,
            formId: transfert.formId,
            totalParts: parts.length,
            partIndex: i + 1,
            tlvFields: parts[i],
          );
          final partEncoded = encodeBytes(partMsg, _encoderType);
          final ok = await ussdTransport.sendPart(partEncoded);

          if (!ok) {
            await localDataSource.updateStatus(transfert.numeroFiche, 'echec');
            return Left(ServerFailure("Échec partie ${i + 1}"));
          }
          sentCount++;
          await localDataSource.updatePartsInfo(
            transfert.numeroFiche,
            parts.length,
            sentCount,
          );
        }

        await localDataSource.updateStatus(
          transfert.numeroFiche,
          'envoyé_ussd',
        );
        return Right(
          SubmissionResult(
            submissionId: transfert.numeroFiche,
            viaHttp: false,
            totalUssdParts: parts.length,
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure("Erreur inattendue: $e"));
    }
  }

  @override
  Future<int> syncPendingHttpTransferts() async {
    final pending = await localDataSource.getPendingTransferts();
    int count = 0;
    for (var t in pending) {
      try {
        log("Numero Fiche fetching url ${t.numeroFiche}");
        final url = await remoteDataSource.getUploadUrl(
          'Fiche de transfert ${t.numeroFiche}',
          t.username,
        );
        final fields = jsonDecode(t.fieldsJson ?? '{}') as Map<String, dynamic>;

        // Calcul taille totale
        int totalBytes = 0;
        for (var r in t.receipts) {
          if (r.imagePath.isNotEmpty) {
            final f = File(r.imagePath);
            if (await f.exists()) {
              totalBytes += await f.length();
            }
          }
        }

        final totalMB = totalBytes / 1024 / 1024;
        log(
          'SYNC ${t.numeroFiche} | '
          '${t.receipts.length} receipts | '
          '${totalMB.toStringAsFixed(2)} MB',
          name: 'SYNC_HTTP',
        );

        final Map<String, dynamic> httpFields = Map.from(fields);
        httpFields.remove('receipts');

        // Convert main image to base64 if it exists
        if (t.image != null && t.image!.isNotEmpty) {
          final imageFile = File(t.image!);
          if (await imageFile.exists()) {
            final bytes = await imageFile.readAsBytes();
            httpFields['image'] = base64Encode(bytes);
            log('Main image converted to Base64 (${bytes.length} bytes)');
          }
        }

        // Submit transfer data
        final transferPayload = {"form_id": t.formId, "fields": httpFields};

        await remoteDataSource.uploadTransfert(
          url: url,
          payload: transferPayload,
        );

        // Submit each receipt separately
        for (var receipt in t.receipts) {
          String base64Image = "";
          if (receipt.imagePath.isNotEmpty) {
            final file = File(receipt.imagePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              base64Image = base64Encode(bytes);
            }
          }

          final receiptUrl = await remoteDataSource.getUploadUrl(
            '${t.numeroFiche}_receipt_${receipt.receiptNumber}',
            t.username,
          );

          final receiptPayload = {
            "form_id": t.formId,
            "fields": {
              "bundle_id": t.bundleId,
              "numeroRecu": receipt.receiptNumber,
              "image": base64Image,
              "campagne": t.campagne,
            },
          };

          await remoteDataSource.uploadTransfert(
            url: receiptUrl,
            payload: receiptPayload,
          );
        }

        await localDataSource.updateStatus(t.numeroFiche, 'synchronisé');
        count++;
      } catch (e) {
        log("Sync failed for ${t.numeroFiche}: $e");
      }
    }
    return count;
  }
}
