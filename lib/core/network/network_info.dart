abstract class NetworkInfo {
  /// Vérifie si le téléphone a une connexion internet (WiFi/Données)
  Future<bool> get isConnected;

  /// Écoute les changements de connectivité (Internet réel)
  Stream<bool> get onConnectivityChanged;
}
