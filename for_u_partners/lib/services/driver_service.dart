import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/course_model.dart';

class DriverService {
  Future<void> acceptCourse(int courseId) async {
    final url = Uri.parse(acceptCourseUrl(courseId));
    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<void> rejectCourse(int courseId) async {
    final url = Uri.parse(rejectCourseUrl(courseId));
    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<void> startCourse(int courseId) async {
    final url = Uri.parse(startCourseUrl(courseId));
    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<void> completeCourse(int courseId) async {
    final url = Uri.parse(completeCourseUrl(courseId));
    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
    }
  }

  Future<FactureCourse> fetchFactureCourse(int courseId) async {
    final url = Uri.parse(factureCourseUrl(courseId));
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FactureCourse.fromJson(data);
    } else {
      throw Exception("Erreur ${response.statusCode} : ${response.body}");
    }
  }

  Future<List<CoursePendingModel>> fetchCoursesPending() async {
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
    final url = Uri.parse(coursesDetailsUrl(courseId));
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseDetail.fromJson(data);
    } else {
      throw Exception("Erreur ${response.statusCode} : ${response.body}");
    }
  }
}
