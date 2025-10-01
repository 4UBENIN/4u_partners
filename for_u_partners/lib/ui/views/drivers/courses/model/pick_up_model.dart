class PickUpModel {
  final String message;
  final PickUpData data;

  PickUpModel({
    required this.message,
    required this.data,
  });

  factory PickUpModel.fromJson(Map<String, dynamic> json) {
    return PickUpModel(
      message: json['message'] as String,
      data: PickUpData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class PickUpData {
  final int id;
  final int clientId;
  final int serviceId;
  final String adresseDepart;
  final double departLat;
  final double departLng;
  final String adresseArrivee;
  final double destinationLat;
  final double destinationLng;
  final String dateRsv;
  final String heuresRsv;
  final String categorie;
  double distanceKm;
  double dureeEstimee;
  final double montant;
  final String statut;
  final String createdAt;
  DriverInfo? driverInfo;

  PickUpData({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.adresseDepart,
    required this.departLat,
    required this.departLng,
    required this.adresseArrivee,
    required this.destinationLat,
    required this.destinationLng,
    required this.dateRsv,
    required this.heuresRsv,
    required this.categorie,
    required this.distanceKm,
    required this.dureeEstimee,
    required this.montant,
    required this.statut,
    required this.createdAt,
    this.driverInfo,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static PickUpData fromJson(Map<String, dynamic> json) {
    return PickUpData(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      adresseDepart: json['adresse_depart'] ?? '',
      departLat: _parseDouble(json['depart_lat']),
      departLng: _parseDouble(json['depart_lng']),
      adresseArrivee: json['adresse_arrivee'] ?? '',
      destinationLat: _parseDouble(json['destination_lat']),
      destinationLng: _parseDouble(json['destination_lng']),
      dateRsv: json['date_rsv'] ?? '',
      heuresRsv: json['heures_rsv'] ?? '',
      categorie: json['categorie'] ?? '',
      distanceKm: _parseDouble(json['distance_km']),
      dureeEstimee: _parseDouble(json['duree_estimee'] ?? json['duree']),
      montant: _parseDouble(json['montant']),
      statut: json['statut'] ?? 'en_attente',
      createdAt: json['created_at'] ?? '',
      // Gestion à la fois de 'chauffeur' et 'conducteur' pour la rétrocompatibilité
      driverInfo: (json['conducteur'] ?? json['chauffeur']) != null 
          ? DriverInfo.fromJson((json['conducteur'] ?? json['chauffeur']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'service_id': serviceId,
      'conducteur': driverInfo?.toJson(),
      'adresse_depart': adresseDepart,
      'depart_lat': departLat,
      'depart_lng': departLng,
      'adresse_arrivee': adresseArrivee,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'date_rsv': dateRsv,
      'heures_rsv': heuresRsv,
      'categorie': categorie,
      'distance_km': distanceKm,
      'duree_estimee': dureeEstimee,
      'montant': montant,
      'statut': statut,
      'created_at': createdAt,
    };
  }
}

class DriverInfo {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? photoUrl;
  final String? noteMoyenne;

  DriverInfo({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.photoUrl,
    this.noteMoyenne,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? json['photo'],
      noteMoyenne: json['note_moyenne']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'photo_url': photoUrl,
      'note_moyenne': noteMoyenne,
    };
  }

  String get fullName => '$prenom $nom';
}

class PickUpParams {
  String? typeCourse;
  String? adresseDepart;
  double? departLat;
  double? departLng;
  String? adresseArrivee;
  double? arriveeLat;
  double? arriveeLng;
  String? dateRsv;
  String? heuresRsv;
  String? categorie;
  String? typeVehicule;

  PickUpParams(
      {this.typeCourse,
      this.adresseDepart,
      this.departLat,
      this.departLng,
      this.adresseArrivee,
      this.arriveeLat,
      this.arriveeLng,
      this.dateRsv,
      this.heuresRsv,
      this.categorie,
      this.typeVehicule});

  PickUpParams.fromJson(Map<String, dynamic> json) {
    typeCourse = json['type_course'];
    adresseDepart = json['adresse_depart'];
    departLat = json['depart_lat'];
    departLng = json['depart_lng'];
    adresseArrivee = json['adresse_arrivee'];
    arriveeLat = json['arrivee_lat'];
    arriveeLng = json['arrivee_lng'];
    dateRsv = json['date_rsv'];
    heuresRsv = json['heures_rsv'];
    categorie = json['categorie'];
    typeVehicule = json['type_vehicule'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type_course'] = typeCourse;
    data['adresse_depart'] = adresseDepart;
    data['depart_lat'] = departLat;
    data['depart_lng'] = departLng;
    data['adresse_arrivee'] = adresseArrivee;
    data['arrivee_lat'] = arriveeLat;
    data['arrivee_lng'] = arriveeLng;
    data['date_rsv'] = dateRsv;
    data['heures_rsv'] = heuresRsv;
    data['categorie'] = categorie;
    data['type_vehicule'] = typeVehicule;
    return data;
  }
}