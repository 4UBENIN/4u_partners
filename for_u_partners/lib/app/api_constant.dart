String baseUrl = "https://foryou.cilassocies.com/api";
String registerUrl = "$baseUrl/partenaire/register";
String loginUrl = "$baseUrl/partenaire/login";
String coursesPendingUrl = "$baseUrl/conducteur/courses";
String acceptCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/accept";
String rejectCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/deny";
String startCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/start";
String completeCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/finish";
String factureCourseUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/facture";
String coursesDetailsUrl(int courseId) =>
    "$baseUrl/conducteur/courses/$courseId/details";
String assignedCourseUrl = "$baseUrl/conducteur/courses_list";
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json'
};
