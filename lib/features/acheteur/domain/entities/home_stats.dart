/// Une entité simple pour contenir les statistiques de la page d'accueil.
class HomeStats {
  final int valides;
  final int enAttente;
  final int reclassifyes;

  HomeStats({this.valides = 0, this.enAttente = 0, this.reclassifyes = 0});
}
