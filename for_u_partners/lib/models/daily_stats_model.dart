class DailyStats {
  final double porteFeuille;
  final int totalActiviteToday;
  final int montantGainToday;
  final ActiviteEnCours? activiteEnCours;
  final ActiviteRecenteTerminee? activiteRecenteTerminee;
  final List<Evaluation> dernieresEvaluations;

  DailyStats({
    required this.porteFeuille,
    required this.totalActiviteToday,
    required this.montantGainToday,
    this.activiteEnCours,
    this.activiteRecenteTerminee,
    required this.dernieresEvaluations,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      porteFeuille: (json['porte_feuille'] as num).toDouble(),
      totalActiviteToday: json['total_activite_today'] as int,
      montantGainToday: json['montant_gain_today'] as int,
      activiteEnCours: json['activite_en_cours'] != null
          ? ActiviteEnCours.fromJson(
              json['activite_en_cours'] as Map<String, dynamic>)
          : null,
      activiteRecenteTerminee: json['activite_recente_terminee'] != null
          ? ActiviteRecenteTerminee.fromJson(
              json['activite_recente_terminee'] as Map<String, dynamic>)
          : null,
      dernieresEvaluations: (json['dernieres_evaluations'] as List<dynamic>?)
              ?.map((e) => Evaluation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ActiviteEnCours {
  final String clientNom;
  final String clientPrenom;
  final double distanceKm;

  ActiviteEnCours({
    required this.clientNom,
    required this.clientPrenom,
    required this.distanceKm,
  });

  factory ActiviteEnCours.fromJson(Map<String, dynamic> json) {
    return ActiviteEnCours(
      clientNom: json['client_nom'] as String,
      clientPrenom: json['client_prenom'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }
}

class ActiviteRecenteTerminee {
  final String adresseDepart;
  final String adresseArrivee;
  final DateTime heureArrivee;

  ActiviteRecenteTerminee({
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.heureArrivee,
  });

  factory ActiviteRecenteTerminee.fromJson(Map<String, dynamic> json) {
    return ActiviteRecenteTerminee(
      adresseDepart: json['adresse_depart'] as String,
      adresseArrivee: json['adresse_arrivee'] as String,
      heureArrivee: DateTime.parse(json['heure_arrivee'] as String),
    );
  }
}

class Evaluation {
  final String clientNom;
  final String clientPrenom;
  final int etoiles;
  final String commentaire;

  Evaluation({
    required this.clientNom,
    required this.clientPrenom,
    required this.etoiles,
    required this.commentaire,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      clientNom: json['client_nom'] as String,
      clientPrenom: json['client_prenom'] as String,
      etoiles: json['etoiles'] as int,
      commentaire: json['commentaire'] as String,
    );
  }
}
