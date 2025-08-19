import 'dart:convert';
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

  Future<void> acceptCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(acceptCourseUrl(courseId));
    print(url);
    final response = await http.patch(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print("accept-body: ${response.body}");

    final responseJson = jsonDecode(response.body);
    if (response.statusCode == 200) {
    } else {
      throw responseJson['error'];
    }
  }

  Future<void> rejectCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(rejectCourseUrl(courseId));
    final response = await http.patch(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<void> startCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(startCourseUrl(courseId));
    final response = await http.patch(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<void> completeCourse(int courseId) async {
    final token = await sharedPreferencesService.getToken();
    final url = Uri.parse(completeCourseUrl(courseId));
    final response = await http.patch(url, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

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

  Future<List<CourseAssignedItem>> fetchCourses() async {
    final url = Uri.parse(assignedCourseUrl);
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return parseCoursesResponse(response.body);
    } else {
      throw Exception("Erreur lors du chargement des courses");
    }
  }

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

  Future<int> fetchWalletSold() async {
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
      return data['solde'] as int;
    } else {
      throw Exception("Erreur ${response.body}");
    }
  }

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

  // Récupère la liste des courses du conducteur
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

  // Récupère les détails d'une course spécifique
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
