import 'dart:convert';

import 'package:for_u_partners/services/course_event_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseNotificationStorage {
  static const String _keyPrefix = 'course_notifications';
  static const String _listKey = 'course_notification_ids';

  // ✨ Sauvegarder une notification
  static Future<void> saveNotification(CourseNotificationData course) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les données de la course
      final courseKey = '${_keyPrefix}_${course.courseId}';
      await prefs.setString(courseKey, jsonEncode(course.toJson()));

      // Mettre à jour la liste des IDs
      final existingIds = prefs.getStringList(_listKey) ?? [];
      if (!existingIds.contains(course.courseId)) {
        existingIds.add(course.courseId);
        await prefs.setStringList(_listKey, existingIds);
      }

      print('✅ Notification sauvegardée: ${course.courseId}');
    } catch (e) {
      print('❌ Erreur sauvegarde notification: $e');
    }
  }

  // ✨ Récupérer toutes les notifications valides
  static Future<List<CourseNotificationData>> getValidNotifications({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_listKey) ?? [];
      final validNotifications = <CourseNotificationData>[];

      for (final id in ids) {
        final courseKey = '${_keyPrefix}_$id';
        final jsonString = prefs.getString(courseKey);

        if (jsonString != null) {
          try {
            final course = CourseNotificationData.fromJson(
              jsonDecode(jsonString),
            );

            // Vérifier si elle est encore valide
            if (course.isStillValid(maxAge: maxAge)) {
              validNotifications.add(course);
            } else {
              // Supprimer les notifications expirées
              await _removeNotification(id);
            }
          } catch (e) {
            print('❌ Erreur parsing notification $id: $e');
            await _removeNotification(id);
          }
        }
      }

      // Trier par timestamp (plus récent en premier)
      validNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('📱 ${validNotifications.length} notifications valides récupérées');
      return validNotifications;
    } catch (e) {
      print('❌ Erreur récupération notifications: $e');
      return [];
    }
  }

  // ✨ Récupérer une notification spécifique
  static Future<CourseNotificationData?> getNotification(
      String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final courseKey = '${_keyPrefix}_$courseId';
      final jsonString = prefs.getString(courseKey);

      if (jsonString != null) {
        final course = CourseNotificationData.fromJson(jsonDecode(jsonString));

        if (course.isStillValid()) {
          return course;
        } else {
          await _removeNotification(courseId);
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération notification $courseId: $e');
      return null;
    }
  }

  // ✨ Supprimer une notification
  static Future<void> removeNotification(String courseId) async {
    await _removeNotification(courseId);
  }

  // Méthode privée pour supprimer
  static Future<void> _removeNotification(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Supprimer les données
      final courseKey = '${_keyPrefix}_$courseId';
      await prefs.remove(courseKey);

      // Mettre à jour la liste des IDs
      final existingIds = prefs.getStringList(_listKey) ?? [];
      existingIds.remove(courseId);
      await prefs.setStringList(_listKey, existingIds);

      print('🗑️ Notification supprimée: $courseId');
    } catch (e) {
      print('❌ Erreur suppression notification: $e');
    }
  }

  // ✨ Nettoyer toutes les notifications expirées
  static Future<void> cleanExpiredNotifications({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_listKey) ?? [];
      final expiredIds = <String>[];

      for (final id in ids) {
        final courseKey = '${_keyPrefix}_$id';
        final jsonString = prefs.getString(courseKey);

        if (jsonString != null) {
          try {
            final course = CourseNotificationData.fromJson(
              jsonDecode(jsonString),
            );

            if (!course.isStillValid(maxAge: maxAge)) {
              expiredIds.add(id);
            }
          } catch (e) {
            expiredIds.add(id);
          }
        } else {
          expiredIds.add(id);
        }
      }

      // Supprimer toutes les notifications expirées
      for (final id in expiredIds) {
        await _removeNotification(id);
      }

      print('🧹 ${expiredIds.length} notifications expirées supprimées');
    } catch (e) {
      print('❌ Erreur nettoyage notifications: $e');
    }
  }

  // ✨ Compter les notifications valides
  static Future<int> getValidNotificationCount({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final notifications = await getValidNotifications(maxAge: maxAge);
    return notifications.length;
  }

  // ✨ Vider toutes les notifications
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_listKey) ?? [];

      // Supprimer toutes les données
      for (final id in ids) {
        final courseKey = '${_keyPrefix}_$id';
        await prefs.remove(courseKey);
      }

      // Vider la liste des IDs
      await prefs.remove(_listKey);

      print('🧹 Toutes les notifications supprimées');
    } catch (e) {
      print('❌ Erreur suppression toutes notifications: $e');
    }
  }
}
