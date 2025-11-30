import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/notification_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:http/http.dart' as http;

class NotificationsViewModel extends BaseViewModel {
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setBusy(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final token = await _sharedPreferencesService.getToken();

      final response = await http.get(
        Uri.parse(ApiConstant.getDriverNotifications),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final notificationsList = jsonData['notifications'] as List;

        _notifications = notificationsList
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();

        _hasError = false;
      } else {
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement des notifications';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erreur de connexion';
      print('Error fetching notifications: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await _sharedPreferencesService.getToken();

      final response = await http.post(
        Uri.parse(ApiConstant.markNotificationAsRead(notificationId)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Update the notification's read status locally
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            titre: _notifications[index].titre,
            message: _notifications[index].message,
            type: _notifications[index].type,
            image: _notifications[index].image,
            isRead: true,
            sentAt: _notifications[index].sentAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
