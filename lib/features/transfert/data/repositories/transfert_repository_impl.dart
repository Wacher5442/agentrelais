import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

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
  // On ne garde que l'essentiel pour l'USSD afin de limiter le nombre de SMS
  final List<String> _ussdFieldsWhitelist = [
    'numeroFiche',
    'sticker',
    'typeTransfert',
    'sacs',
    'poids',
    'codeAcheteur',
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
      final submissionId = _generateShortSubmissionId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final fieldsMap = transfert.toFieldsJson();
      final fieldsJson = jsonEncode(fieldsMap);

      // 1. Préparer les champs selon le mode d'envoi
      // Si USSD : on utilise la liste blanche fixe. Sinon : tous les champs.
      final isActuallyUssd = forceUssd || !(await networkInfo.isConnected);

      final tlvFields = TlvFieldMappings.mapFromDto(
        fieldsMap,
        submissionId,
        transfert.agentId,
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
        submissionId: submissionId,
        formId: transfert.formId,
        status: 'draft',
        submissionMethod: isActuallyUssd ? 'ussd' : 'http',
        agentId: transfert.agentId,
        createdAt: now,
        updatedAt: now,
        payload: fullMessage,
        encodedPreview: encodedPreview,
        fieldsJson: fieldsJson,
        totalParts: 1,
        partsSent: 0,
        numeroFiche: transfert.numeroFiche,
        typeTransfert: transfert.typeTransfert,
        sticker: transfert.sticker,
        receipts: transfert.receipts,
      );

      await localDataSource.insertTransfert(model);

      // 3. Tentative HTTP (si non forcé USSD et internet dispo)
      if (!forceUssd && await networkInfo.isConnected) {
        try {
          final url = await remoteDataSource.getUploadUrl(submissionId);

          // Convert receipts to Base64
          final receiptsList = <Map<String, dynamic>>[];
          for (var receipt in transfert.receipts) {
            String base64Image = "";
            if (receipt.imagePath.isNotEmpty) {
              final file = File(receipt.imagePath);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                base64Image = base64Encode(bytes);
              }
            }
            receiptsList.add({
              "receipt_number": receipt.receiptNumber,
              // "image": base64Image,
              "sub_prefecture": 29,
              "bags_purchased": 118,
              "total_weight": 7080,
              "unit_price": 538,
              "producer": "TEST",
            });
          }

          final payload = {
            "transfer_id": submissionId,
            "fields": fieldsMap,
            "receipts": receiptsList,
          };

          await remoteDataSource.uploadTransfert(url: url, payload: payload);

          await localDataSource.updateStatus(submissionId, 'synchronisé');
          return Right(
            SubmissionResult(submissionId: submissionId, viaHttp: true),
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
        await localDataSource.updateStatus(submissionId, status);
        await localDataSource.updatePartsInfo(submissionId, 1, success ? 1 : 0);

        if (!success) return Left(ServerFailure("Échec envoi USSD"));
        return Right(
          SubmissionResult(
            submissionId: submissionId,
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
            await localDataSource.updateStatus(submissionId, 'echec');
            return Left(ServerFailure("Échec partie ${i + 1}"));
          }
          sentCount++;
          await localDataSource.updatePartsInfo(
            submissionId,
            parts.length,
            sentCount,
          );
        }

        await localDataSource.updateStatus(submissionId, 'envoyé_ussd');
        return Right(
          SubmissionResult(
            submissionId: submissionId,
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
        final url = await remoteDataSource.getUploadUrl(t.submissionId);
        final fields = jsonDecode(t.fieldsJson ?? '{}') as Map<String, dynamic>;

        // Convert receipts to Base64
        final receiptsList = <Map<String, dynamic>>[];
        for (var receipt in t.receipts) {
          String base64Image = "";
          if (receipt.imagePath.isNotEmpty) {
            final file = File(receipt.imagePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              base64Image = base64Encode(bytes);
            }
          }
          receiptsList.add({
            "receipt_number": receipt.receiptNumber,
            // "image": base64Image,
            "sub_prefecture": 29,
            "bags_purchased": 118,
            "total_weight": 7080,
            "unit_price": 538,
            "producer": "TEST",
          });
        }

        final payload = {
          "transfer_id": t.submissionId,
          "fields": fields,
          "receipts": receiptsList,
        };

        log("Uploading transfert: $payload");
        await remoteDataSource.uploadTransfert(url: url, payload: payload);
        await localDataSource.updateStatus(t.submissionId, 'synchronisé');
        count++;
      } catch (e) {
        log("Sync failed for ${t.submissionId}: $e");
      }
    }
    return count;
  }

  String _generateShortSubmissionId() {
    return const Uuid().v4().substring(0, 8).toUpperCase();
  }
}
