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
    // Helper function to safely parse numeric values
    num? parseNumber(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    return DailyStats(
      porteFeuille: parseNumber(json['porte_feuille'])?.toDouble() ?? 0.0,
      totalActiviteToday:
          parseNumber(json['total_activite_today'])?.toInt() ?? 0,
      montantGainToday: parseNumber(json['montant_gain_today'])?.toInt() ?? 0,
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
  final String destinationClient;
  final int idActivite;

  ActiviteEnCours({
    required this.clientNom,
    required this.clientPrenom,
    required this.distanceKm,
    required this.destinationClient,
    required this.idActivite,
  });

  factory ActiviteEnCours.fromJson(Map<String, dynamic> json) {
    return ActiviteEnCours(
      clientNom: json['client_nom'] as String? ?? '',
      clientPrenom: json['client_prenom'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      destinationClient: json['destination_client'] as String? ?? '',
      idActivite: (json['id_activite'] as num?)?.toInt() ?? 0,
    );
  }
}

class ActiviteRecenteTerminee {
  final String adresseDepart;
  final String adresseArrivee;
  final DateTime? heureArrivee;
  final int montant;

  ActiviteRecenteTerminee({
    required this.adresseDepart,
    required this.adresseArrivee,
    this.heureArrivee,
    required this.montant,
  });

  factory ActiviteRecenteTerminee.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values
    num? parseNumber(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    return ActiviteRecenteTerminee(
      adresseDepart: json['adresse_depart'] as String? ?? '',
      adresseArrivee: json['adresse_arrivee'] as String? ?? '',
      heureArrivee: json['heure_arrivee'] != null
          ? DateTime.tryParse(json['heure_arrivee'] as String)
          : null,
      montant: parseNumber(json['montant'])?.toInt() ?? 0,
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
      clientNom: json['client_nom'] as String? ?? '',
      clientPrenom: json['client_prenom'] as String? ?? '',
      etoiles: (json['etoiles'] as num?)?.toInt() ?? 0,
      commentaire: json['commentaire'] as String? ?? '',
    );
  }
}
