// Modèle de données pour les activités
class ActivityModel {
  final String type;
  final String route;
  final ActivityStatus status;
  final String timeAgo;
  final String distance;
  final String earning;
  final String? totalTime;
  final String? tarifkm;

  ActivityModel({
    required this.type,
    required this.route,
    required this.status,
    required this.timeAgo,
    required this.distance,
    required this.earning,
    this.totalTime,
    this.tarifkm,
  });

  // Fonction pour calculer le temps écoulé depuis la fin de la course
  static String getTimeAgo(DateTime endTime) {
    final now = DateTime.now();
    final difference = now.difference(endTime);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }
}

enum ActivityStatus { completed, cancelled, inprogress }
