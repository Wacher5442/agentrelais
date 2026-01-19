// lib/core/transport/ussd_transport.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:agent_relais/core/services/ussd_service.dart';

import '../constants/ussd_constants.dart';

abstract class UssdTransport {
  Future<bool> sendPart(String encodedPart);
}

class MockUssdTransport implements UssdTransport {
  final Duration delay;
  MockUssdTransport({this.delay = const Duration(milliseconds: 300)});

  @override
  Future<bool> sendPart(String encodedPart) async {
    final dial = '$USSD_SERVICE_CODE$encodedPart#';
    log("encodedPart $encodedPart");
    print('[MOCK USSD] Dial: $dial (length=${encodedPart.length})');
    // _executeUssd(dial);
    return true;
  }

  // @override
  // Future<bool> sendPart(String encodedPart) async {
  //   try {
  //     log('[MOCK USSD] Sending part to backend');
  //     log('[MOCK USSD] payload length=${encodedPart.length}');
  //     log('[MOCK USSD] payload=$encodedPart');

  //     await Future.delayed(delay);

  //     final response = await http.post(
  //       Uri.parse('$BASE_URL/form/v1/ussd/part'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'encoded_message': encodedPart,
  //         'encoding': 'base32',
  //         'phone_number': '2250123456789',
  //         'session_id': '1234567890',
  //       }),
  //     );

  //     log('[MOCK USSD] backend status=${response.statusCode}');
  //     log('[MOCK USSD] backend response=${response.body}');

  //     return response.statusCode == 200;
  //   } catch (e, s) {
  //     log('[MOCK USSD] error', error: e, stackTrace: s);
  //     return false;
  //   }
  // }

  void _executeUssd(String code) async {
    UssdService.initialize(
      onResponse: (response) {
        log("response ussd $response");
      },
      onState: (state) {
        log("state ussd $state");
      },
    );

    final formattedCode = UssdService.formatUssdCode(code, {});

    final result = await UssdService.executeUssd(formattedCode);

    if (!result.success) {
      log("result ussd $result");
    }
  }
}
