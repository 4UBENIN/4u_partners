// Modèle de données pour les activités
class ActivityModel {
  final int id;
  final String numero;
  final String type;
  final String route;
  final String adresseDepart;
  final String adresseArrivee;
  final ActivityStatus status;
  final String timeAgo;
  final String distance;
  final String earning;
  final String? totalTime;
  final String? tarifkm;
  final String? modePaiement;
  final Map<String, dynamic>? vehicule;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? pointDepart;
  final Map<String, dynamic>? pointArrivee;
  final DateTime dateCreation;

  ActivityModel({
    required this.id,
    required this.numero,
    required this.type,
    required this.route,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.status,
    required this.timeAgo,
    required this.distance,
    required this.earning,
    this.totalTime,
    this.tarifkm,
    this.modePaiement,
    this.vehicule,
    this.client,
    this.pointDepart,
    this.pointArrivee,
    required this.dateCreation,
  });

  // Constructeur à partir des données de l'API
  factory ActivityModel.fromApiData(Map<String, dynamic> data) {
    final status = _parseStatus(data['statut']);
    final dateCreation =
        DateTime.parse(data['créée_le'] ?? DateTime.now().toString());

    return ActivityModel(
      id: data['course_id'] ?? data['id'],
      numero: data['numero'] ?? '',
      type: data['vehicule']?['categorie'] ?? 'standard',
      route:
          '${data['adresse_depart']} → ${data['adresse_arrivee'] ?? data['point_arrivee']?['adresse']}',
      adresseDepart:
          data['adresse_depart'] ?? data['point_depart']?['adresse'] ?? '',
      adresseArrivee:
          data['adresse_arrivee'] ?? data['point_arrivee']?['adresse'] ?? '',
      status: status,
      timeAgo: getTimeAgo(dateCreation),
      distance: '${data['distance_km']?.toStringAsFixed(1) ?? '0'} km',
      earning: '${data['montant']?.toStringAsFixed(0) ?? '0'} CFA',
      modePaiement: data['mode_paiement'],
      vehicule: data['vehicule'],
      client: data['client'],
      pointDepart: data['point_depart'],
      pointArrivee: data['point_arrivee'],
      dateCreation: dateCreation,
    );
  }

  // Convertir le statut de l'API en enum ActivityStatus
  static ActivityStatus _parseStatus(String status) {
    switch (status) {
      case 'termine':
        return ActivityStatus.completed;
      case 'annule':
        return ActivityStatus.cancelled;
      case 'en_cours':
      case 'chauffeur_en_route':
        return ActivityStatus.inprogress;
      case 'en_attente':
      default:
        return ActivityStatus.pending;
    }
  }

  // Fonction pour calculer le temps écoulé depuis la fin de la course
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }
}

enum ActivityStatus { completed, cancelled, inprogress, pending }
