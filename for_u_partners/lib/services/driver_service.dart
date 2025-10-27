import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/course_model.dart';
import '../models/daily_stats_model.dart';
import '../models/global_stats_model.dart';
import '../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverLocation {
  final int id;
  final double latitude;
  final double longitude;
  final String? name;

  DriverLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.name,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      id: json['id'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      name: json['utilisateur'] != null
          ? '${json['utilisateur']['prenom']} ${json['utilisateur']['nom']}'
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DriverService {
  // URL de l'API pour les conducteurs en ligne
  static const String onlineDriversUrl =
      'https://foryou.cilassocies.com/api/conducteur/en-ligne';

  // Passer en mode en ligne
  Future<void> goOnline() async {
    final token = await sharedPreferencesService.getToken();
    const url = 'https://foryou.cilassocies.com/api/conducteur/online';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("go-online-response: ${response.body}");
      if (response.statusCode != 200) {
        throw Exception('Erreur lors du passage en mode en ligne');
      }
    } catch (e) {
      debugPrint('Erreur goOnline: $e');
      rethrow;
    }
  }

  // Passer en mode hors ligne
  Future<void> goOffline() async {
    final token = await sharedPreferencesService.getToken();
    const url = 'https://foryou.cilassocies.com/api/conducteur/offline';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("go-offline-response: ${response.body}");
      if (response.statusCode != 200) {
        throw Exception('Erreur lors du passage en mode hors ligne');
      }
    } catch (e) {
      debugPrint('Erreur goOffline: $e');
      rethrow;
    }
  }

  // Récupérer la liste des conducteurs en ligne avec leurs coordonnées
  Future<List<DriverLocation>> getOnlineDrivers() async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(onlineDriversUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> drivers = data['data'];
          return drivers
              .map((driver) => DriverLocation.fromJson(driver))
              .toList();
        } else {
          throw Exception(
              'Erreur lors de la récupération des conducteurs: ${data['message']}');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des conducteurs en ligne: $e');
      rethrow;
    }
  }

  final sharedPreferencesService = locator<SharedpreferencesService>();

  // Accepter une course
  Future<void> acceptCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(acceptCourseUrl(courseId));

    try {
      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("accept-course-response: ${response.body}");

      if (response.statusCode == 200) {
        // La course a été acceptée avec succès
        return jsonDecode(response.body);
      } else {
        throw Exception('Échec de l\'acceptation de la course');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'acceptation de la course: $e');
      rethrow;
    }
  }

  // Rejeter une course
  Future<void> rejectCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(rejectCourseUrl(courseId));
    print("reject-course-url: $url");

    try {
      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("reject-course-response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Échec du rejet de la course');
      }
    } catch (e) {
      debugPrint('Erreur lors du rejet de la course: $e');
      rethrow;
    }
  }

  // Démarrer une course
  Future<void> startCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(startCourseUrl(courseId));
    print("start-course-url: $url");
    try {
      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("start-course-response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Échec du démarrage de la course');
      }
    } catch (e) {
      debugPrint('Erreur lors du démarrage de la course: $e');
      rethrow;
    }
  }

  // Démarrer une pause
  Future<Map<String, dynamic>> startPause(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(startPauseUrl(courseId));
    print("start-pause-url: $url");
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("start-pause-response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'timestamp': data['timestamp'] as int,
          'pause_start': data['pause_start'] as String,
        };
      } else {
        throw Exception('Échec du démarrage de la pause');
      }
    } catch (e) {
      debugPrint('Erreur lors du démarrage de la pause: $e');
      rethrow;
    }
  }

  // Arrêter une pause
  Future<Map<String, dynamic>> stopPause(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(stopPauseUrl(courseId));
    print("stop-pause-url: $url");
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("stop-pause-response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'pause_seconds': data['pause_seconds'] as int,
          'total_pause': data['total_pause'] as int,
          'montant_pause': data['montant_pause'] as int,
          'message': data['message'] as String,
        };
      } else {
        throw Exception('Échec de l\'arrêt de la pause');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'arrêt de la pause: $e');
      rethrow;
    }
  }

  // Terminer une course
  Future<void> completeCourse(int courseId) async {
    print("Debut de la fin de la course dans le service");
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(completeCourseUrl(courseId));
    print("complete-course-url: $url");

    try {
      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("complete-course-response: ${response.body}");

      if (response.statusCode != 200) {
        // Try to parse error message from response
        try {
          final responseData = jsonDecode(response.body);
          final errorMessage = responseData['message'] ?? responseData['error'];

          if (errorMessage != null && errorMessage.toString().contains('pause')) {
            throw Exception('Impossible de terminer la course : une pause est en cours. Veuillez reprendre la course avant de la terminer.');
          }

          throw Exception(errorMessage ?? 'Échec de la finalisation de la course');
        } catch (e) {
          if (e.toString().contains('pause')) {
            rethrow;
          }
          throw Exception('Échec de la finalisation de la course');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la finalisation de la course: $e');
      rethrow;
    }
  }

  // Récupérer les détails d'une course
  Future<Map<String, dynamic>> getRideDetails(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse('$baseUrl/conducteur/courses/$courseId/detail');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          'Get ride details response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Erreur inconnue';
        throw Exception('Échec de la récupération des détails: $error');
      }
    } catch (e) {
      debugPrint('Error getting ride details: $e');
      rethrow;
    }
  }

  // Récupérer la facture d'une course
  Future<FactureCourse> fetchFactureCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse(factureCourseUrl(courseId));
    print("url: $url");
    final response = await http.get(url, headers: headers);

    print("facture-body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FactureCourse.fromJson(data);
    } else {
      throw Exception("Erreur ${response.statusCode} : ${response.body}");
    }
  }

  // Récupérer les courses en attente
  Future<List<CoursePendingModel>> fetchCoursesPending() async {
    final token = await sharedPreferencesService.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse(coursesPendingUrl);
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> dataList = decoded['data'];

      return dataList.map((item) => CoursePendingModel.fromJson(item)).toList();
    } else {
      throw Exception("Erreur ${response.statusCode} : ${response.body}");
    }
  }

  // Récupérer les courses assignées
  Future<List<CourseAssignedItem>> fetchCourses() async {
    final url = Uri.parse(assignedCourseUrl);
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return parseCoursesResponse(response.body);
    } else {
      throw Exception("Erreur lors du chargement des courses");
    }
  }

  // Récupérer les détails d'une course
  Future<CourseDetail> fetchCourseDetail(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse(coursesDetailsUrl(courseId));
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseDetail.fromJson(data);
    } else {
      throw Exception("Erreur ${response.statusCode} : ${response.body}");
    }
  }

  // Récupérer la balance du portefeuille
  Future<double> fetchWalletSold() async {
    final token = await sharedPreferencesService.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse(walletSoldUrl);
    final response = await http.get(url, headers: headers);
    print("wallet-body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['balance'] as num).toDouble();
    } else {
      throw Exception("Erreur ${response.body}");
    }
  }

  // Récupérer les statistiques quotidiennes
  Future<DailyStats> fetchDailyStats() async {
    final token = await sharedPreferencesService.getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final url = Uri.parse(getDailyStats);
      final response = await http.get(url, headers: headers);

      print("daily-stats-response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("daily-stats-response: ${DailyStats.fromJson(responseData)}");
        return DailyStats.fromJson(responseData);
      } else {
        throw Exception(
            'Erreur lors de la récupération des statistiques: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur dans fetchDailyStats: $e');
      rethrow;
    }
  }

  // Récupérer les statistiques globales
  Future<GlobalStats> fetchGlobalStats() async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(getGlobalStats);

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return GlobalStats.fromJson(responseData);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ??
          'Échec du chargement des statistiques globales');
    }
  }

  // Récupérer le profil de l'utilisateur
  Future<UserModel> getUserProfile() async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse('$baseUrl/user/profile');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return UserModel.fromJson(responseData['user']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Échec du chargement du profil');
    }
  }

  // Mettre à jour le profil de l'utilisateur
  Future<UserModel> updateUserProfile({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    String? adresse,
    String? dateNaissance,
    String? genre,
  }) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse('$baseUrl/user/updateprofile');

    final body = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      if (adresse != null) 'adresse': adresse,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      if (genre != null) 'genre': genre,
    };

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return UserModel.fromJson(responseData['user']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Échec de la mise à jour du profil');
    }
  }

  // Récupérer la liste des courses du conducteur
  Future<List<Map<String, dynamic>>> getCoursesList() async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse('$baseUrl/conducteur/courses_list');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('=== COURSES LIST DEBUG ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Full Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint('Parsed Response: $responseData');

      final courses = List<Map<String, dynamic>>.from(responseData['courses']);
      debugPrint('Number of courses: ${courses.length}');

      for (var i = 0; i < courses.length; i++) {
        debugPrint('--- Course $i ---');
        debugPrint('Full Course Data: ${courses[i]}');
        debugPrint('Status: ${courses[i]['statut']}');
        debugPrint('ID: ${courses[i]['id']}');
      }
      debugPrint('=== END COURSES LIST DEBUG ===');

      return courses;
    } else {
      debugPrint('Error Response: ${response.body}');
      throw Exception('Échec du chargement des courses');
    }
  }

  // Récupérer les détails d'une course spécifique
  Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse('$baseUrl/conducteur/courses/$courseId/detail');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('=== COURSE DETAILS DEBUG ===');
    debugPrint('Course ID: $courseId');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Full Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final details = jsonDecode(response.body);
      debugPrint('Parsed Details: $details');
      debugPrint('Available Keys: ${details.keys.toList()}');
      debugPrint('=== END COURSE DETAILS DEBUG ===');
      return details;
    } else {
      debugPrint('Error Response: ${response.body}');
      throw Exception('Échec du chargement des détails de la course');
    }
  }

  Future<void> notifyClient(int courseId) async {
    try {
      final token = await sharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('Token non disponible');
      }

      final url = Uri.parse('$baseUrl/conducteur/courses/$courseId/notif');
      final now = DateTime.now().toUtc();
      final heureArriveePayload = {
        'date':
            now.toIso8601String().replaceFirst('T', ' ').replaceFirst('Z', ''),
        'timezone_type': 3,
        'timezone': 'UTC',
      };

      print('🔔 Notification URL: $url');
      print(
          '🔔 Sending PATCH request with timestamp: ${now.toIso8601String()}');

      final response = await http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'heure_arrivee': heureArriveePayload,
          'heure_arrivee_iso8601': now.toIso8601String(),
        }),
      );

      debugPrint('=== NOTIFY CLIENT RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Full Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('Parsed Response Data: $responseData');

        // Log each field separately for clarity
        responseData.forEach((key, value) {
          debugPrint('  $key: $value');
        });

        debugPrint('✅ Notification successful');
      } else {
        debugPrint('⚠️ Notification responded with ${response.statusCode}, continuing workflow.');
      }

      debugPrint('=== END NOTIFY CLIENT RESPONSE ===');
    } catch (e) {
      print('❌ Error in notifyClient (non-blocking): $e');
    }
  }

  Future<void> updateWallet(int amount, BuildContext context) async {
    final token = await sharedPreferencesService.getToken();
    try {
      print('Sending amount: $amount');

      final response = await http
          .post(
            Uri.parse("https://foryou.cilassocies.com/api/wallet_recharge"),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: {
              'montant': amount.toString(),
            },
            encoding: Encoding.getByName('utf-8'),
          )
          .timeout(const Duration(seconds: 30));

      // Log request details
      if (response.request is http.Request) {
        final req = response.request as http.Request;
        print('Request URL: ${req.url}');
        print('Request Headers: ${req.headers}');
        print('Request Body: ${req.body}');
      }

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String paymentUrl = data['payment_url'];
        print('Lien de paiement : $paymentUrl');

        final Uri uri = Uri.parse(paymentUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception("Impossible d'ouvrir le lien: $paymentUrl");
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Échec de la mise à jour';
        print('Erreur : $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau : $e');
      throw Exception('Erreur lors de la mise à jour du wallet: $e');
    }
  }

  Future<void> postdriverheartbeat(double lat, double long) async {
    final token = await sharedPreferencesService.getToken();
    if (token == null) {
      throw Exception('Token non disponible');
    }
    print("post-driver-heartbeat: $lat $long");

    final url = Uri.parse('$baseUrl/conducteur/heartbeat');
    print('Notification URL: $url');

    final response = await http.post(url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'latitude': lat,
          'longitude': long,
        }));

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Échec de la notification au client');
    }
    print("post-driver-heartbeat-response: ${response.body}");
  }
}
