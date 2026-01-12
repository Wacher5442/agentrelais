import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class UssdService {
  static const MethodChannel _channel = MethodChannel('ussd_channel');
  static Function(String)? _onResponse;
  static Function(String)? _onState;

  // Initialiser le service USSD
  static void initialize({
    Function(String)? onResponse,
    Function(String)? onState,
  }) {
    _onResponse = onResponse;
    _onState = onState;

    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onUssdResponse':
        _onResponse?.call(call.arguments);
        break;
      case 'onUssdState':
        _onState?.call(call.arguments);
        break;
    }
    return null;
  }

  // Vérifier et demander les permissions (maintenant publique)
  static Future<bool> checkAndRequestPermissions() async {
    // Vérifier d'abord si on a déjà la permission
    var status = await Permission.phone.status;

    if (!status.isGranted) {
      // Demander la permission
      status = await Permission.phone.request();

      if (!status.isGranted) {
        // Si l'utilisateur refuse, ouvrir les paramètres
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }

    return true;
  }

  // Exécuter un code USSD avec vérification des permissions
  static Future<UssdResult> executeUssd(String code) async {
    try {
      // Vérifier les permissions d'abord
      final hasPermission = await checkAndRequestPermissions();

      if (!hasPermission) {
        return UssdResult(
          success: false,
          error: 'Permissions téléphone non accordées',
          response: null,
        );
      }

      // Vérifier si le service a les permissions natives
      final hasNativePermission = await _channel.invokeMethod(
        'hasUssdPermission',
      );

      if (!hasNativePermission) {
        return UssdResult(
          success: false,
          error: 'Permissions système manquantes',
          response: null,
        );
      }

      // Exécuter le code USSD
      final bool success = await _channel.invokeMethod('executeUssd', {
        'code': code,
      });

      return UssdResult(
        success: success,
        error: success ? null : 'Échec de l\'exécution',
        response: null,
      );
    } on PlatformException catch (e) {
      return UssdResult(
        success: false,
        error: 'Erreur: ${e.message}',
        response: null,
      );
    }
  }

  // Formater le code USSD
  static String formatUssdCode(String baseCode, Map<String, dynamic> data) {
    String formattedCode = baseCode;

    data.forEach((key, value) {
      formattedCode = formattedCode.replaceFirst('{$key}', value.toString());
    });

    if (!formattedCode.endsWith('#')) {
      formattedCode += '#';
    }

    return formattedCode;
  }

  // Vérifier simplement les permissions sans demander
  static Future<bool> hasPermissions() async {
    final status = await Permission.phone.status;
    return status.isGranted;
  }
}

// Classe pour gérer les résultats USSD
class UssdResult {
  final bool success;
  final String? error;
  final String? response;

  UssdResult({required this.success, this.error, this.response});
}
