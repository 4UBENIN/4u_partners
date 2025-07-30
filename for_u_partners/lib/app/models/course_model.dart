import 'dart:convert';

class CoursePendingModel {
  final int courseId;
  final int clientId;
  final String clientNom;
  final String clientPrenom;
  final double departLat;
  final double departLng;
  final String adresseDepart;
  final double pickupDistanceKm;
  final int dureeEstimee;

  CoursePendingModel({
    required this.courseId,
    required this.clientId,
    required this.clientNom,
    required this.clientPrenom,
    required this.departLat,
    required this.departLng,
    required this.adresseDepart,
    required this.pickupDistanceKm,
    required this.dureeEstimee,
  });

  factory CoursePendingModel.fromJson(Map<String, dynamic> json) {
    return CoursePendingModel(
      courseId: json['course_id'],
      clientId: json['client_id'],
      clientNom: json['client_nom'],
      clientPrenom: json['client_prenom'],
      departLat: (json['depart_lat'] as num).toDouble(),
      departLng: (json['depart_lng'] as num).toDouble(),
      adresseDepart: json['adresse_depart'],
      pickupDistanceKm: (json['pickup_distance_km'] as num).toDouble(),
      dureeEstimee: json['duree_estimee'],
    );
  }
}

class FactureCourse {
  final int courseId;
  final String adresseDepart;
  final String adresseArrivee;
  final double distanceKm;
  final int dureeMin;
  final int montant;
  final String modePaiement;
  final int tarifParMinute;
  final int tarifParKm;

  // Tu peux remplacer les types Map<String, dynamic> par des classes précises pour `vehicule`, `chauffeur`, `client` si besoin.
  final Map<String, dynamic> vehicule;
  final Map<String, dynamic> chauffeur;
  final Map<String, dynamic> client;

  FactureCourse({
    required this.courseId,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.distanceKm,
    required this.dureeMin,
    required this.montant,
    required this.modePaiement,
    required this.tarifParMinute,
    required this.tarifParKm,
    required this.vehicule,
    required this.chauffeur,
    required this.client,
  });

  factory FactureCourse.fromJson(Map<String, dynamic> json) {
    return FactureCourse(
      courseId: json['course_id'],
      adresseDepart: json['adresse_depart'],
      adresseArrivee: json['adresse_arrivee'],
      distanceKm: (json['distance_km'] as num).toDouble(),
      dureeMin: json['duree_min'],
      montant: json['montant'],
      modePaiement: json['mode_paiement'],
      tarifParMinute: json['tarif_par_minute'],
      tarifParKm: json['tarif_par_km'],
      vehicule: json['vehicule'] ?? {},
      chauffeur: json['chauffeur'] ?? {},
      client: json['client'] ?? {},
    );
  }
}

class CourseDetail {
  final int courseId;
  final String statut;
  final double distanceKm;
  final int montant;
  final String modePaiement;
  final Map<String, dynamic> vehicule;
  final Map<String, dynamic> chauffeur;
  final Map<String, dynamic> client;
  final Map<String, dynamic> pointDepart;
  final Map<String, dynamic> pointArrivee;

  CourseDetail({
    required this.courseId,
    required this.statut,
    required this.distanceKm,
    required this.montant,
    required this.modePaiement,
    required this.vehicule,
    required this.chauffeur,
    required this.client,
    required this.pointDepart,
    required this.pointArrivee,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      courseId: json['course_id'],
      statut: json['statut'],
      distanceKm: (json['distance_km'] as num).toDouble(),
      montant: json['montant'],
      modePaiement: json['mode_paiement'],
      vehicule: json['vehicule'] ?? {},
      chauffeur: json['chauffeur'] ?? {},
      client: json['client'] ?? {},
      pointDepart: json['point_depart'] ?? {},
      pointArrivee: json['point_arrivee'] ?? {},
    );
  }
}

class CourseAssignedItem {
  final int id;
  final String numero;
  final String adresseDepart;
  final String adresseArrivee;
  final String statut;
  final DateTime creeLe;

  CourseAssignedItem({
    required this.id,
    required this.numero,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.statut,
    required this.creeLe,
  });

  factory CourseAssignedItem.fromJson(Map<String, dynamic> json) {
    return CourseAssignedItem(
      id: json['id'],
      numero: json['numero'],
      adresseDepart: json['adresse_depart'],
      adresseArrivee: json['adresse_arrivee'],
      statut: json['statut'],
      creeLe: DateTime.parse(json['créée_le']),
    );
  }
}

List<CourseAssignedItem> parseCoursesResponse(String body) {
  final jsonData = jsonDecode(body);
  final List<dynamic> coursesJson = jsonData['courses'];
  return coursesJson.map((e) => CourseAssignedItem.fromJson(e)).toList();
}