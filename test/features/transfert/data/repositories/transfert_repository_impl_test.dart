import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agent_relais/core/network/network_info.dart';
import 'package:agent_relais/core/utils/ussd_transport.dart'
    hide MockUssdTransport;
import 'package:agent_relais/features/transfert/data/datasources/local/transfert_local_datasource.dart';
import 'package:agent_relais/features/transfert/data/datasources/remote/transfert_remote_datasource.dart';
import 'package:agent_relais/features/transfert/data/models/transfert_model.dart';
import 'package:agent_relais/features/transfert/data/repositories/transfert_repository_impl.dart';
import 'package:agent_relais/features/transfert/domain/entities/receipt_entity.dart';
import 'package:agent_relais/features/transfert/domain/entities/transfert_entity.dart';

import 'transfert_repository_impl_test.mocks.dart';

@GenerateMocks([
  TransfertLocalDataSource,
  TransfertRemoteDataSource,
  NetworkInfo,
  UssdTransport,
])
void main() {
  late TransfertRepositoryImpl repository;
  late MockTransfertLocalDataSource mockLocalDataSource;
  late MockTransfertRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockUssdTransport mockUssdTransport;

  setUp(() {
    mockLocalDataSource = MockTransfertLocalDataSource();
    mockRemoteDataSource = MockTransfertRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockUssdTransport = MockUssdTransport();
    repository = TransfertRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
      ussdTransport: mockUssdTransport,
    );
  });

  final tReceipts = [
    ReceiptEntity(imagePath: 'path/to/img1.jpg', receiptNumber: 'REC001'),
    ReceiptEntity(imagePath: 'path/to/img2.jpg', receiptNumber: 'REC002'),
  ];

  final tTransfert = TransfertEntity(
    submissionId: 'SUB123',
    formId: 5,
    status: 'draft',
    submissionMethod: 'http',
    agentId: 'AGENT007',
    createdAt: 1234567890,
    updatedAt: 1234567890,
    receipts: tReceipts,
    numeroFiche: 'FICHE001',
    typeTransfert: 'ORDINAIRE',
    sticker: 'STICKER001',
  );

  group('submitTransfert', () {
    test(
      'should fetch URL and upload with enriched payload when online',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.getUploadUrl(any),
        ).thenAnswer((_) async => 'https://api.example.com/upload');
        when(
          mockLocalDataSource.insertTransfert(any),
        ).thenAnswer((_) async => 1);
        when(
          mockLocalDataSource.updateStatus(any, any),
        ).thenAnswer((_) async => 1);
        when(
          mockRemoteDataSource.uploadTransfert(
            url: anyNamed('url'),
            payload: anyNamed('payload'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.submitTransfert(
          transfert: tTransfert,
          forceUssd: false,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockRemoteDataSource.getUploadUrl(any)).called(1);
        verify(
          mockRemoteDataSource.uploadTransfert(
            url: anyNamed('url'),
            payload: anyNamed('payload'),
          ),
        ).called(1);
      },
    );
  });
}
