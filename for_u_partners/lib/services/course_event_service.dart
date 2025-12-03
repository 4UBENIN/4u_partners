import 'dart:async';

import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';

// Modèle pour les données de course reçues via Firebase
class CourseNotificationData {
  final String courseId;
  final String clientId;
  final String clientNom;
  final String clientPrenom;
  final String adresseDepart;
  final String adresseArrivee;
  final double distance;
  final double duree;
  final double prix;
  final String typeCourse;
  final bool isNight;
  final int etaMinutes;
  final double destLong;
  final double destLat;
  final double depLong;
  final double depLat;
  final DateTime timestamp;
  final int? serviceId; // ⚡ Added to identify pickup courses (service_id = 3)

  CourseNotificationData(
    this.clientId, {
    required this.courseId,
    required this.clientNom,
    required this.clientPrenom,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.distance,
    required this.duree,
    required this.prix,
    required this.typeCourse,
    required this.isNight,
    required this.etaMinutes,
    required this.destLong,
    required this.destLat,
    required this.depLong,
    required this.depLat,
    this.serviceId, // ⚡ Added
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Créer depuis les données Firebase
  factory CourseNotificationData.fromFirebaseData(
    Map<String, dynamic> data, {
    DateTime? receivedAt, // ✨ Paramètre optionnel pour le timestamp
  }) {
    return CourseNotificationData(
      data['client_id']?.toString() ?? '',
      courseId: data['course_id']?.toString() ?? '',
      clientNom: data['client_nom']?.toString() ?? '',
      clientPrenom: data['client_prenom']?.toString() ?? '',
      adresseDepart: data['adresse_depart']?.toString() ?? '',
      adresseArrivee: data['adresse_arrivee']?.toString() ?? '',
      distance: double.tryParse(data['distance']?.toString() ?? '0') ?? 0.0,
      duree: double.tryParse(data['duree']?.toString() ?? '0') ?? 0.0,
      prix: double.tryParse(data['prix']?.toString() ?? '0') ?? 0.0,
      typeCourse: data['type_course']?.toString() ?? '',
      isNight: data['is_night']?.toString() == '1',
      etaMinutes: int.tryParse(data['eta_minutes']?.toString() ?? '0') ?? 0,
      destLong:
          double.tryParse(data['destination_lng']?.toString() ?? '0') ?? 0.0,
      destLat:
          double.tryParse(data['destination_lat']?.toString() ?? '0') ?? 0.0,
      depLong: double.tryParse(data['depart_lng']?.toString() ?? '0') ?? 0.0,
      depLat: double.tryParse(data['depart_lat']?.toString() ?? '0') ?? 0.0,
      serviceId: int.tryParse(data['service_id']?.toString() ?? ''), // ⚡ Added
      timestamp: receivedAt, // ✨ Utilise le timestamp fourni ou DateTime.now()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'courseId': courseId,
      'clientNom': clientNom,
      'clientPrenom': clientPrenom,
      'adresseDepart': adresseDepart,
      'adresseArrivee': adresseArrivee,
      'distance': distance,
      'duree': duree,
      'prix': prix,
      'typeCourse': typeCourse,
      'isNight': isNight,
      'etaMinutes': etaMinutes,
      'destLong': destLong,
      'destLat': destLat,
      'depLong': depLong,
      'depLat': depLat,
      'serviceId': serviceId, // ⚡ Added
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // ✨ Créer depuis JSON
  factory CourseNotificationData.fromJson(Map<String, dynamic> json) {
    return CourseNotificationData(
      json['clientId']?.toString() ?? '',
      courseId: json['courseId'] ?? '',
      clientNom: json['clientNom'] ?? '',
      clientPrenom: json['clientPrenom'] ?? '',
      adresseDepart: json['adresseDepart'] ?? '',
      adresseArrivee: json['adresseArrivee'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
      duree: (json['duree'] ?? 0.0).toDouble(),
      prix: (json['prix'] ?? 0.0).toDouble(),
      typeCourse: json['typeCourse'] ?? '',
      isNight: json['isNight'] ?? false,
      etaMinutes: json['etaMinutes'] ?? 0,
      destLong: (json['destLong'] ?? 0.0).toDouble(),
      destLat: (json['destLat'] ?? 0.0).toDouble(),
      depLong: (json['depLong'] ?? 0.0).toDouble(),
      depLat: (json['depLat'] ?? 0.0).toDouble(),
      serviceId: json['serviceId'] as int?, // ⚡ Added
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  bool isStillValid({Duration maxAge = const Duration(minutes: 4)}) {
    final now = DateTime.now();
    return now.difference(timestamp) <= maxAge;
  }

  // Convertir vers votre modèle ClientData existant
  ClientData toClientData() {
    String initials = '';
    if (clientPrenom.isNotEmpty) initials += clientPrenom[0];
    if (clientNom.isNotEmpty) initials += clientNom[0];

    // Calculer le temps estimé d'arrivée (exemple : distance * 2 minutes par km)
    String timeInfo = 'À $etaMinutes minutes de vous';

    return ClientData(
      name: '$clientPrenom $clientNom',
      clientId: clientId,
      timeInfo: timeInfo,
      destination: adresseArrivee,
      initials: initials.isNotEmpty ? initials : 'C',
      courseId: courseId,
      prix: prix,
      distance: distance,
      duree: duree,
      adresseDepart: adresseDepart,
      isNight: isNight,
      etaMinutes: etaMinutes,
      destLong: destLong,
      destLat: destLat,
      depLong: depLong,
      depLat: depLat,
      serviceId: serviceId, // ⚡ Added to properly identify pickup courses
    );
  }

  @override
  String toString() {
    return 'CourseNotificationData(courseId: $courseId, client: $clientPrenom $clientNom, prix: $prix)';
  }
}

// Modèle pour les événements d'annulation de course
class CourseCancellationEvent {
  final String courseId;
  final String? reason;
  final Map<String, dynamic> rawData;

  CourseCancellationEvent({
    required this.courseId,
    this.reason,
    Map<String, dynamic>? rawData,
  }) : rawData = rawData ?? const {};
}

// Service pour gérer les événements de course
class CourseEventService {
  static final CourseEventService _instance = CourseEventService._internal();
  factory CourseEventService() => _instance;
  CourseEventService._internal();

  // Stream pour les nouvelles courses
  final StreamController<CourseNotificationData> _newCourseController =
      StreamController<CourseNotificationData>.broadcast();

  // Stream pour les mises à jour de courses
  final StreamController<CourseNotificationData> _courseUpdateController =
      StreamController<CourseNotificationData>.broadcast();

  // Stream pour les annulations de course
  final StreamController<CourseCancellationEvent> _courseCancelController =
      StreamController<CourseCancellationEvent>.broadcast();

  // Getters pour écouter les streams
  Stream<CourseNotificationData> get newCourseStream =>
      _newCourseController.stream;
  Stream<CourseNotificationData> get courseUpdateStream =>
      _courseUpdateController.stream;
  Stream<CourseCancellationEvent> get courseCancelStream =>
      _courseCancelController.stream;

  // Méthode appelée depuis FirebaseMessagingService
  void onNewCourseReceived(Map<String, dynamic> firebaseData) {
    try {
      final courseData = CourseNotificationData.fromFirebaseData(firebaseData);
      print('📱 Nouvelle course reçue: ${courseData.toString()}');
      _newCourseController.add(courseData);
    } catch (e) {
      print('❌ Erreur parsing course data: $e');
    }
  }

  // Méthode pour les mises à jour de course
  void onCourseUpdated(Map<String, dynamic> firebaseData) {
    try {
      final courseData = CourseNotificationData.fromFirebaseData(firebaseData);
      print('🔄 Course mise à jour: ${courseData.toString()}');
      _courseUpdateController.add(courseData);
    } catch (e) {
      print('❌ Erreur parsing course update: $e');
    }
  }

  // Méthode appelée lorsqu'une course est annulée
  void onCourseCancelled(Map<String, dynamic> firebaseData) {
    try {
      final courseId = firebaseData['course_id']?.toString() ?? '';
      if (courseId.isEmpty) {
        print('⚠️ Impossible de traiter l\'annulation: course_id manquant');
        return;
      }

      final reason = firebaseData['reason']?.toString() ??
          firebaseData['motif']?.toString();

      print('❌ Course annulée: $courseId');
      _courseCancelController.add(
        CourseCancellationEvent(
          courseId: courseId,
          reason: reason,
          rawData: firebaseData,
        ),
      );
    } catch (e) {
      print('❌ Erreur parsing course cancellation: $e');
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _newCourseController.close();
    _courseUpdateController.close();
    _courseCancelController.close();
  }
}
