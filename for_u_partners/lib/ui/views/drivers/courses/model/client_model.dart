class ClientData {
  final String name;
  final String timeInfo;
  final String destination;
  final String initials;

  // ✨ Nouvelles propriétés depuis Firebase
  final String? courseId;
  final String? clientId;
  final double? prix;
  final double? distance;
  final double? duree;
  final String? adresseDepart;
  final bool? isNight;

  final int? etaMinutes;
  final double? destLong;
  final double? destLat;
  final double? depLong;
  final double? depLat;

  // ✨ Service ID to identify pickup courses (service_id = 3)
  final int? serviceId;

  // Phone number of the client
  final String? phoneNumber;

  // Vehicle type for calculating waiting fees
  final String? vehicleType;

  ClientData({
    required this.name,
    required this.timeInfo,
    required this.destination,
    required this.initials,
    this.clientId,
    this.courseId,
    this.prix,
    this.distance,
    this.duree,
    this.adresseDepart,
    this.isNight,
    this.etaMinutes,
    this.destLong,
    this.destLat,
    this.depLong,
    this.depLat,
    this.serviceId,
    this.phoneNumber,
    this.vehicleType,
  });

  // Helper to check if this is a pickup course
  bool get isPickupCourse => serviceId == 3;

  // ✨ Méthodes utiles
  String get formattedPrice =>
      prix != null ? '${prix!.toStringAsFixed(0)} FCFA' : 'Prix non défini';

  String get formattedDistance => distance != null
      ? '${distance!.toStringAsFixed(1)} km'
      : 'Distance inconnue';

  String get formattedDuration =>
      duree != null ? '${duree!.toStringAsFixed(0)} min' : 'Durée inconnue';

  bool get hasValidCourseId => courseId != null && courseId!.isNotEmpty;

  // Ajout des méthodes de sérialisation/désérialisation
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timeInfo': timeInfo,
      'destination': destination,
      'initials': initials,
      'courseId': courseId,
      'prix': prix,
      'distance': distance,
      'duree': duree,
      'adresseDepart': adresseDepart,
      'isNight': isNight,
      'etaMinutes': etaMinutes,
      'destLong': destLong,
      'destLat': destLat,
      'depLong': depLong,
      'depLat': depLat,
      'serviceId': serviceId,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
    };
  }

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      name: json['name'] as String,
      timeInfo: json['timeInfo'] as String,
      destination: json['destination'] as String,
      initials: json['initials'] as String,
      courseId: json['courseId'] as String?,
      prix: json['prix']?.toDouble(),
      distance: json['distance']?.toDouble(),
      duree: json['duree']?.toDouble(),
      adresseDepart: json['adresseDepart'] as String?,
      isNight: json['isNight'] as bool?,
      etaMinutes: json['etaMinutes'] as int?,
      destLong: json['destLong']?.toDouble(),
      destLat: json['destLat']?.toDouble(),
      depLong: json['depLong']?.toDouble(),
      depLat: json['depLat']?.toDouble(),
      serviceId: json['serviceId'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
    );
  }

  @override
  String toString() {
    return 'ClientData(name: $name, courseId: $courseId, prix: $prix)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientData && other.courseId == courseId;
  }

  @override
  int get hashCode => courseId?.hashCode ?? 0;
}
