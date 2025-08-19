class ClientData {
  final String name;
  final String timeInfo;
  final String destination;
  final String initials;

  // ✨ Nouvelles propriétés depuis Firebase
  final String? courseId;
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
  ClientData({
    required this.name,
    required this.timeInfo,
    required this.destination,
    required this.initials,
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
  });

  // ✨ Méthodes utiles
  String get formattedPrice =>
      prix != null ? '${prix!.toStringAsFixed(0)} FCFA' : 'Prix non défini';

  String get formattedDistance => distance != null
      ? '${distance!.toStringAsFixed(1)} km'
      : 'Distance inconnue';

  String get formattedDuration =>
      duree != null ? '${duree!.toStringAsFixed(0)} min' : 'Durée inconnue';

  bool get hasValidCourseId => courseId != null && courseId!.isNotEmpty;

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
