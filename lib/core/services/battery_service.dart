import 'package:flutter/services.dart';

class BatteryService {
  // Channel pour les méthodes
  static const MethodChannel _methodChannel = MethodChannel(
    'battery_method_channel',
  );

  // Channel pour les événements
  static const EventChannel _eventChannel = EventChannel(
    'battery_event_channel',
  );

  // Obtenir le niveau de batterie instantané
  static Future<int> getBatteryLevel() async {
    try {
      final int level = await _methodChannel.invokeMethod('getBatteryLevel');
      return level;
    } on PlatformException catch (e) {
      print(
        "Erreur lors de la récupération du niveau de batterie: ${e.message}",
      );
      return -1;
    }
  }

  // Stream pour surveiller les changements en temps réel
  static Stream<Map<String, dynamic>> get batteryStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      return Map<String, dynamic>.from(event);
    });
  }
}
