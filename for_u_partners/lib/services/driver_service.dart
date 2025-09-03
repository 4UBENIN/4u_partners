import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/course_model.dart';
import '../models/daily_stats_model.dart';
import '../models/global_stats_model.dart';
import '../models/user_model.dart';

class DriverService {
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
        throw Exception('Échec de la finalisation de la course');
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

  // Récupérer le solde du portefeuille
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
      return (data['solde'] as num).toDouble();
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

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData['courses']);
    } else {
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

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec du chargement des détails de la course');
    }
  }
}
